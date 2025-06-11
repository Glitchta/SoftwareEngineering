-- 用户权限视图
CREATE VIEW v_user_permissions AS
SELECT 
  id AS user_id,
  permission,
  CASE 
    WHEN permission = 'admin' THEN 1 
    ELSE 0 
  END AS is_admin
FROM user;