DELIMITER $$

-- 存储过程：获取用户详细信息
CREATE PROCEDURE `sp_get_user_details`(
  IN p_requested_by INT,  -- 请求者用户ID (用于权限验证)
  IN p_user_id INT        -- 要查看的用户ID
)
BEGIN
  DECLARE v_is_admin TINYINT DEFAULT 0;
  DECLARE v_target_exists TINYINT DEFAULT 0;
  
  /* 1. 验证目标用户存在 */
  SELECT COUNT(*) INTO v_target_exists 
  FROM `user` 
  WHERE `id` = p_user_id;
  
  IF v_target_exists = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'User does not exist', 
      MYSQL_ERRNO = 1001;
  END IF;
  
  /* 2. 验证查看权限 */
  -- 获取请求者权限
  SELECT `permission` = 'admin' INTO v_is_admin 
  FROM `user` 
  WHERE `id` = p_requested_by;
  
  -- 非管理员只能查看自己的信息
  IF p_requested_by != p_user_id AND v_is_admin = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Permission denied: can only view own profile', 
      MYSQL_ERRNO = 1002;
  END IF;
  
  /* 3. 返回用户基本信息 */
  SELECT 
    `id` AS user_id,
    `permission`,
    DATE(`created_at`) AS register_date,
    DATE(`last_login`) AS last_login_date
  FROM `user`
  WHERE `id` = p_user_id;
  
  /* 4. 返回用户创建的问卷统计 */
  SELECT 
    COUNT(`id`) AS questionnaire_count,
    MAX(`created_at`) AS last_created
  FROM `questionnaire`
  WHERE `creator_id` = p_user_id;
  
  /* 5. 返回最近创建的5份问卷 */
  SELECT 
    `id` AS questionnaire_id,
    `title` AS questionnaire_title,
    `created_at`
  FROM `questionnaire`
  WHERE `creator_id` = p_user_id
  ORDER BY `created_at` DESC
  LIMIT 5;
  
  /* 6. 返回活动统计（如果存在答案表）*/
  -- 首先检查答案表是否存在
  IF (
    SELECT COUNT(*)
    FROM information_schema.TABLES 
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'answer'
  ) > 0 THEN
    -- 参与问卷数量
    SELECT COUNT(DISTINCT q.questionnaire_id) AS participated_count
    FROM `answer` a
    JOIN `question` q ON a.question_id = q.id
    WHERE a.user_id = p_user_id;
    
    -- 最后参与时间
    SELECT MAX(`created_at`) AS last_participated
    FROM `answer`
    WHERE `user_id` = p_user_id;
    
    -- 最常回答的问卷类型
    SELECT 
      q.type AS question_type,
      COUNT(*) AS answer_count
    FROM `answer` a
    JOIN `question` q ON a.question_id = q.id
    WHERE a.user_id = p_user_id
    GROUP BY q.type
    ORDER BY answer_count DESC
    LIMIT 1;
  END IF;
  
  /* 7. 管理员专属信息 */
  IF v_is_admin = 1 THEN
    -- 账户状态（需要扩展user表）
    IF EXISTS (
      SELECT COLUMN_NAME 
      FROM information_schema.COLUMNS 
      WHERE TABLE_NAME = 'user' 
        AND COLUMN_NAME = 'status'
    ) THEN
      SELECT `status` FROM `user` WHERE `id` = p_user_id;
    END IF;
    
    -- IP登录记录（需要单独表）
    IF EXISTS (
      SELECT TABLE_NAME 
      FROM information_schema.TABLES 
      WHERE TABLE_NAME = 'login_log'
    ) THEN
      SELECT `ip_address`, `login_time`
      FROM `login_log`
      WHERE `user_id` = p_user_id
      ORDER BY `login_time` DESC
      LIMIT 5;
    END IF;
  END IF;
END
$$

DELIMITER ;