-- 用户表 (存储系统用户信息)
CREATE TABLE `user` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
  `password` VARCHAR(100) NOT NULL COMMENT '密码',
  `permission` ENUM('admin','normal') NOT NULL DEFAULT 'normal' COMMENT '权限: admin-管理员, normal-普通用户',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 问卷表 (存储问卷基本信息)
CREATE TABLE `questionnaire` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '问卷ID',
  `title` VARCHAR(200) NOT NULL COMMENT '问卷标题',
  `creator_id` INT UNSIGNED NOT NULL COMMENT '创建人ID',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  CONSTRAINT `fk_questionnaire_creator`
    FOREIGN KEY (`creator_id`) REFERENCES `user` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 问卷项表 (存储问卷中的问题)
CREATE TABLE `question` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '题目ID',
  `questionnaire_id` INT UNSIGNED NOT NULL COMMENT '问卷ID',
  `title` VARCHAR(500) NOT NULL COMMENT '题目',
  `type` ENUM('single_choice','multiple_choice','text') NOT NULL DEFAULT 'single_choice' COMMENT '题型: single_choice-单选, multiple_choice-多选, text-文本',
  `sort_order` INT NOT NULL DEFAULT 0 COMMENT '题目排序',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  CONSTRAINT `fk_question_questionnaire`
    FOREIGN KEY (`questionnaire_id`) REFERENCES `questionnaire` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 选项表 (存储问题选项)
CREATE TABLE `option` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '选项ID',
  `content` TEXT NOT NULL COMMENT '选项内容',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 问卷项-选项关联表 (建立问题与选项的关系)
CREATE TABLE `question_option` (
  `question_id` INT UNSIGNED NOT NULL COMMENT '题目ID',
  `option_id` INT UNSIGNED NOT NULL COMMENT '选项ID',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`question_id`, `option_id`),
  CONSTRAINT `fk_question_option_question`
    FOREIGN KEY (`question_id`) REFERENCES `question` (`id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_question_option_option`
    FOREIGN KEY (`option_id`) REFERENCES `option` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 修改用户表结构
ALTER TABLE user 
MODIFY COLUMN password VARCHAR(100) NOT NULL COMMENT '密码（bcrypt加密）';
ALTER TABLE `user`
ADD COLUMN `email` VARCHAR(100) NULL COMMENT '邮箱',
ADD COLUMN `real_name` VARCHAR(50) NULL COMMENT '真实姓名',
ADD COLUMN `status` ENUM('active','suspended','pending') NOT NULL DEFAULT 'active' COMMENT '账户状态',
ADD COLUMN `last_login` DATETIME NULL COMMENT '最后登录时间',
ADD COLUMN `login_count` INT NOT NULL DEFAULT 0 COMMENT '登录次数';
--日志表
CREATE TABLE audit_log (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED,
  action VARCHAR(50) NOT NULL COMMENT '操作类型',
  details TEXT COMMENT '操作详情',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES user(id)
);
--登录日志表
CREATE TABLE `login_log` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `login_time` DATETIME NOT NULL COMMENT '登录时间',
  `ip_address` VARCHAR(45) NOT NULL COMMENT 'IP地址',
  `user_agent` VARCHAR(255) NULL COMMENT '用户代理',
  KEY `idx_user_login` (`user_id`, `login_time`),
  CONSTRAINT `fk_login_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;