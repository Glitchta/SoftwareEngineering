DELIMITER $$
CREATE PROCEDURE sp_get_full_questionnaire(
  IN p_questionnaire_id INT
)
BEGIN
  -- 获取问卷基本信息
  SELECT id, title, creator_id 
  FROM questionnaire 
  WHERE id = p_questionnaire_id;
  
  -- 获取问题列表
  SELECT 
    id, 
    title, 
    type, 
    sort_order 
  FROM question 
  WHERE questionnaire_id = p_questionnaire_id 
  ORDER BY sort_order;
  
  -- 获取选项数据
  SELECT 
    q.id AS question_id,
    o.id AS option_id,
    o.content AS option_content
  FROM question q
  JOIN question_option qo ON q.id = qo.question_id
  JOIN option o ON qo.option_id = o.id
  WHERE q.questionnaire_id = p_questionnaire_id
  ORDER BY q.sort_order, o.id;
END
$$
DELIMITER ;