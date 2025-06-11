-- 问题选项统计视图
CREATE VIEW v_question_option_counts AS
SELECT 
  q.id AS question_id,
  q.title AS question_title,
  COUNT(o.id) AS option_count
FROM question q
LEFT JOIN question_option qo ON q.id = qo.question_id
LEFT JOIN option o ON qo.option_id = o.id
GROUP BY q.id;