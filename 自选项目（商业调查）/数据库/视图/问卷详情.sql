-- 问卷完整信息视图（包含所有问题及选项）
CREATE VIEW v_questionnaire_details AS
SELECT 
  qn.id AS questionnaire_id,
  qn.title AS questionnaire_title,
  u.id AS creator_id,
  q.id AS question_id,
  q.title AS question_title,
  q.type AS question_type,
  o.id AS option_id,
  o.content AS option_content
FROM questionnaire qn
JOIN user u ON qn.creator_id = u.id
JOIN question q ON qn.id = q.questionnaire_id
LEFT JOIN question_option qo ON q.id = qo.question_id
LEFT JOIN option o ON qo.option_id = o.id
ORDER BY qn.id, q.sort_order, o.id;