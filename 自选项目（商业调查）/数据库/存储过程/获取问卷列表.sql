-- 获取问卷列表带分页
CREATE PROCEDURE sp_get_questionnaire_list(
  IN p_page INT,
  IN p_page_size INT
)
BEGIN
  DECLARE offset_val INT DEFAULT (p_page - 1) * p_page_size;
  
  SELECT id, title, creator_id 
  FROM questionnaire
  ORDER BY id DESC
  LIMIT offset_val, p_page_size;
END;