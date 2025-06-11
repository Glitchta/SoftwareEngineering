DELIMITER $$
CREATE PROCEDURE sp_add_question(
  IN p_questionnaire_id INT,
  IN p_question_title VARCHAR(500),
  IN p_question_type ENUM('single_choice','multiple_choice','text'),
  IN p_options JSON -- 格式: ["选项1", "选项2", ...]
)
BEGIN
  DECLARE v_question_id INT;
  DECLARE i INT DEFAULT 0;
  DECLARE option_count INT;
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;
  
  -- 验证问卷存在
  IF NOT EXISTS (SELECT 1 FROM questionnaire WHERE id = p_questionnaire_id) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Questionnaire does not exist';
  END IF;
  
  START TRANSACTION;
  
  -- 插入问题
  INSERT INTO question (questionnaire_id, title, type) 
  VALUES (p_questionnaire_id, p_question_title, p_question_type);
  
  SET v_question_id = LAST_INSERT_ID();
  
  -- 处理选项（仅选择题）
  IF p_question_type IN ('single_choice','multiple_choice') THEN
    SET option_count = JSON_LENGTH(p_options);
    
    WHILE i < option_count DO
      INSERT INTO question_option (question_id, option_id)
      VALUES (
        v_question_id,
        -- 创建选项并获取ID
        (SELECT id FROM option 
         WHERE content = JSON_UNQUOTE(JSON_EXTRACT(p_options, CONCAT('$[', i, ']')))
         LIMIT 1
        )
      );
      
      -- 如果选项不存在则创建
      IF ROW_COUNT() = 0 THEN
        INSERT INTO option (content) 
        VALUES (JSON_UNQUOTE(JSON_EXTRACT(p_options, CONCAT('$[', i, ']'))));
        
        INSERT INTO question_option (question_id, option_id)
        VALUES (v_question_id, LAST_INSERT_ID());
      END IF;
      
      SET i = i + 1;
    END WHILE;
  END IF;
  
  COMMIT;
  
  SELECT v_question_id AS question_id;
END
$$
DELIMITER ;