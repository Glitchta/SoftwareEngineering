DELIMITER $$
CREATE PROCEDURE sp_authenticate_user(
  IN p_user_id INT,
  IN p_password VARCHAR(100)
)
BEGIN
  DECLARE auth_count INT;
  
  SELECT COUNT(*)
  INTO auth_count
  FROM user
  WHERE id = p_user_id 
    AND password = p_password;
  
  IF auth_count = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Authentication failed';
  ELSE
    SELECT 
      id AS user_id,
      permission
    FROM user
    WHERE id = p_user_id;
  END IF;
END
$$
DELIMITER ;