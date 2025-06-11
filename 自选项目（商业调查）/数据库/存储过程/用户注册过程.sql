DELIMITER $$
CREATE PROCEDURE sp_register_user(
  IN p_password VARCHAR(100),
  IN p_permission ENUM('admin','normal') 
)
BEGIN
  -- 检查权限值是否合法
  IF p_permission NOT IN ('admin','normal') THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Invalid permission value';
  END IF;
  
  -- 插入新用户
  INSERT INTO user (password, permission) 
  VALUES (p_password, p_permission);
  
  SELECT LAST_INSERT_ID() AS user_id;
END
$$
DELIMITER ;