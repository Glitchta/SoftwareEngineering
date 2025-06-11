DELIMITER $$
CREATE PROCEDURE sp_create_questionnaire(
  IN p_title VARCHAR(200),
  IN p_creator_id INT
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;
  
  -- 验证用户存在且有权限
  IF NOT EXISTS (SELECT 1 FROM user WHERE id = p_creator_id) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Creator does not exist';
  END IF;
  
  START TRANSACTION;
  
  -- 创建问卷
  INSERT INTO questionnaire (title, creator_id) 
  VALUES (p_title, p_creator_id);
  
  SELECT LAST_INSERT_ID() AS questionnaire_id;
  
  COMMIT;
END
$$
DELIMITER ;