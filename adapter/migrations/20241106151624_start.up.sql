-- Add up migration script here
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS trigger AS '
  BEGIN
    new.updated_at := ''now'';
    return new;
  END;
' LANGUAGE 'plpgsql';




-- rolesテーブルとusersテーブルを追加
CREATE TABLE IF NOT EXISTS roles(
  role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS users(
  user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role_id UUID NOT NULL,
  created_at TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

  FOREIGN KEY(role_id) REFERENCES roles(role_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE

);

CREATE TRIGGER users_updated_at_trigger
  BEFORE UPDATE ON users FOR EACH ROW
  EXECUTE PROCEDURE set_updated_at();

-- books テーブルに蔵書の所有者を表すuser_idを追記する
-- books tableの作成
CREATE TABLE IF NOT EXISTS books(
    book_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    isbn VARCHAR(255) NOT NULL,
    description VARCHAR(1024) NOT NULL,
    user_id UUID NOT NULL,
    created_at TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- 3. books tableへのトリガーの追加
CREATE TRIGGER books_updated_at_trigger 
  BEFORE UPDATE ON books FOR EACH ROW 
  EXECUTE PROCEDURE set_updated_at();