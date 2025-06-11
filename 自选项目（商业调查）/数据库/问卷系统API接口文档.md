# 问卷系统 API 接口文档

## 1. 用户管理

### 1.1 用户注册

​**​端点​**​: `CALL sp_register_user(password, permission)`
​**​功能​**​: 注册新用户账户
​**​参数​**​:

|参数名|类型|必填|描述|示例|
|-|-|-|-|-|
|password|VARCHAR|是|账户密码|'SecurePass123!'|
|permission|ENUM|是|账户权限 ('admin'或'normal')|'normal'|

​**​返回结果​**​:

- 成功: `{"user_id": 15}`

- 失败: SQL错误 (如无效权限值)

​**​调用示例​**​:

```Java
CALL sp_register_user('MyStrongPassword', 'normal');
```

### 1.2 用户登录

​**​端点​**​: `CALL sp_authenticate_user(user_id, password)`
​**​功能​**​: 验证用户身份
​**​参数​**​:

|参数名|类型|必填|描述|示例|
|-|-|-|-|-|
|user_id|INT|是|用户ID|15|
|password|VARCHAR|是|账户密码|'SecurePass123!'|

​**​返回结果​**​:

- 成功:

    ```Java
    {
      "user_id": 15,
      "permission": "normal"
    }
    ```

- 失败: `Authentication failed` 错误

​**​调用示例​**​:

```Java
CALL sp_authenticate_user(15, 'MyStrongPassword');
```

### 1.3 用户详细信息

​**​端点​**​: `CALL sp_get_user_details(requested_by, user_id)`
​**​功能​**​: 获取用户完整信息
​**​参数​**​:

|参数名|类型|必填|描述|示例|
|-|-|-|-|-|
|requested_by|INT|是|请求者用户ID|1|
|user_id|INT|是|要查询的用户ID|15|

​**​返回结果​**​:
多结果集响应：

1. ​**​用户基本信息​**​:

    ```Java
    [{
      "user_id": 15,
      "permission": "normal",
      "register_date": "2023-08-15",
      "last_login_date": "2023-10-05"
    }]
    ```

1. ​**​问卷统计​**​:

    ```Java
    [{
      "questionnaire_count": 8,
      "last_created": "2023-10-04 14:30:00"
    }]
    ```

1. ​**​最近问卷​**​:

    ```Java
    [{
      "questionnaire_id": 102,
      "questionnaire_title": "客户满意度调查",
      "created_at": "2023-10-04 14:30:00"
    },
    ...最多5条]
    ```

1. ​**​活动统计​**​(如果存在相关表):

    ```Java
    [{
      "participated_count": 22,
      "last_participated": "2023-10-05 10:15:00"
    }]
    ```

1. ​**​管理员专属信息​**​(仅管理员可见):

    ```Java
    [{
      "status": "active"
    }]
    ```

    ```Java
    [{
      "ip_address": "192.168.1.100",
      "login_time": "2023-10-05 10:15:00"
    }]
    ```

​**​错误处理​**​:

- 1001: 用户不存在

- 1002: 权限不足(仅管理员可查看其他用户信息)

​**​调用示例​**​:

```Java
-- 普通用户查看自己的信息
CALL sp_get_user_details(15, 15);

-- 管理员查看其他用户
CALL sp_get_user_details(1, 15);
```

## 2. 问卷管理

### 2.1 创建问卷

​**​端点​**​: `CALL sp_create_questionnaire(title, creator_id)`
​**​功能​**​: 创建新问卷
​**​参数​**​:

|参数名|类型|必填|描述|示例|
|-|-|-|-|-|
|title|VARCHAR|是|问卷标题|'客户满意度调查'|
|creator_id|INT|是|创建者ID|15|

​**​返回结果​**​:

- 成功: `{"questionnaire_id": 102}`

- 失败: `Creator does not exist` 错误

​**​调用示例​**​:

```Java
CALL sp_create_questionnaire('产品反馈问卷', 15);
```

### 2.2 添加问题

​**​端点​**​: `CALL sp_add_question(questionnaire_id, question_title, question_type, options)`
​**​功能​**​: 向问卷添加问题
​**​参数​**​:

|参数名|类型|必填|描述|示例|
|-|-|-|-|-|
|questionnaire_id|INT|是|问卷ID|102|
|question_title|VARCHAR|是|问题标题|'您如何评价我们的产品?'|
|question_type|ENUM|是|问题类型 ('single_choice', 'multiple_choice', 'text')|'single_choice'|
|options|JSON|可选|选项数组(仅选择题需要)|'["非常好", "好", "一般", "差"]'|

​**​返回结果​**​:

- 成功: `{"question_id": 2048}`

- 失败: `Questionnaire does not exist` 错误

​**​调用示例​**​:

```Java
-- 单选题
CALL sp_add_question(102, '产品易用性评分', 'single_choice', '["非常易用", "易用", "一般", "难用"]');

-- 文本题
CALL sp_add_question(102, '您的改进建议', 'text', NULL);
```

### 2.3 获取问卷完整数据

​**​端点​**​: `CALL sp_get_full_questionnaire(questionnaire_id)`
​**​功能​**​: 获取问卷完整结构
​**​参数​**​:

|参数名|类型|必填|描述|示例|
|-|-|-|-|-|
|questionnaire_id|INT|是|问卷ID|102|

​**​返回结果​**​:
多结果集响应：

1. ​**​问卷基本信息​**​:

    ```Java
    [{
      "id": 102,
      "title": "产品反馈问卷",
      "creator_id": 15
    }]
    ```

1. ​**​问题列表​**​:

    ```Java
    [{
      "id": 2048,
      "title": "产品易用性评分",
      "type": "single_choice",
      "sort_order": 1
    },
    {
      "id": 2049,
      "title": "您的改进建议",
      "type": "text",
      "sort_order": 2
    }]
    ```

1. ​**​选项数据​**​(仅选择题):

    ```Java
    [{
      "question_id": 2048,
      "option_id": 501,
      "option_content": "非常易用"
    },
    {
      "question_id": 2048,
      "option_id": 502,
      "option_content": "易用"
    }]
    ```

​**​调用示例​**​:

```Java
CALL sp_get_full_questionnaire(102);
```

## 3. 数据视图

### 3.1 问卷详情视图

​**​视图名称​**​: `v_questionnaire_details`
​**​功能​**​: 提供问卷完整结构(包含问题+选项)
​**​字段​**​:

|字段名|类型|描述|
|-|-|-|
|questionnaire_id|INT|问卷ID|
|questionnaire_title|VARCHAR|问卷标题|
|creator_id|INT|创建者ID|
|question_id|INT|问题ID|
|question_title|VARCHAR|问题标题|
|question_type|ENUM|问题类型|
|option_id|INT|选项ID|
|option_content|TEXT|选项内容|

​**​查询示例​**​:

```Java
SELECT * FROM v_questionnaire_details 
WHERE questionnaire_id = 102;
```

### 3.2 问题统计视图

​**​视图名称​**​: `v_question_option_counts`
​**​功能​**​: 统计每个问题的选项数量
​**​字段​**​:

|字段名|类型|描述|
|-|-|-|
|question_id|INT|问题ID|
|question_title|VARCHAR|问题标题|
|option_count|INT|选项数量|

​**​查询示例​**​:

```Java
SELECT * FROM v_question_option_counts;
```

### 3.3 用户权限视图

​**​视图名称​**​: `v_user_permissions`
​**​功能​**​: 提供用户权限状态
​**​字段​**​:

|字段名|类型|描述|
|-|-|-|
|user_id|INT|用户ID|
|permission|ENUM|权限级别|
|is_admin|TINYINT|是否管理员(1/0)|

​**​查询示例​**​:

```Java
SELECT * FROM v_user_permissions 
WHERE user_id = 15;
```

## 4. 数据报表接口

### 4.1 问卷列表(分页)

​**​端点​**​: `CALL sp_get_questionnaire_list(page, page_size)`
​**​功能​**​: 分页获取问卷列表
​**​参数​**​:

|参数名|类型|必填|描述|示例|
|-|-|-|-|-|
|page|INT|是|页码(从1开始)|1|
|page_size|INT|是|每页数量|10|

​**​返回结果​**​:

```Java
[{
  "id": 101,
  "title": "员工满意度调查",
  "creator_id": 10
},
{
  "id": 102,
  "title": "产品反馈问卷",
  "creator_id": 15
}]
```

​**​调用示例​**​:

```Java
CALL sp_get_questionnaire_list(1, 10);
```

