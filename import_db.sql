DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
 );

 DROP TABLE IF EXISTS questions;

 CREATE TABLE questions (
   id INTEGER PRIMARY KEY,
   title TEXT NOT NULL,
   body TEXT NOT NULL,
   user_id INTEGER NOT NULL,

   FOREIGN KEY (user_id) REFERENCES users(id)
 );

 DROP TABLE IF EXISTS question_follows;

 CREATE TABLE question_follows (
   id INTEGER PRIMARY KEY,
   user_id INTEGER NOT NULL,
   questions_id INTEGER NOT NULL,

   FOREIGN KEY (user_id) REFERENCES users(id)
   FOREIGN KEY ( questions_id) REFERENCES questions(id)
 );

  DROP TABLE IF EXISTS replies;
   CREATE TABLE replies (
     id INTEGER PRIMARY KEY,
     body TEXT,
     replies_id INTEGER,
     user_id INTEGER NOT NULL,
     questions_id INTEGER NOT NULL,

     FOREIGN KEY (user_id) REFERENCES users(id)
     FOREIGN KEY ( questions_id) REFERENCES questions(id)
     FOREIGN KEY (replies_id) REFERENCES replies(id)
   );

   DROP TABLE IF EXISTS question_like;
    CREATE TABLE question_like (
      id INTEGER PRIMARY KEY,
      user_id INTEGER NOT NULL,
      questions_id INTEGER NOT NULL,

      FOREIGN KEY (user_id) REFERENCES users(id)
      FOREIGN KEY ( questions_id) REFERENCES questions(id)
    );

INSERT INTO
  users (fname, lname)
VALUES
  ('Kevin', 'Mckalister'),
  ('James', 'Jones'),
  ('Scrooge','None');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('Kevin''s comment''s', 'This is a cool site!', 1),
  ('James''s comment''s', 'I like this too!', 2);

INSERT INTO
  question_follows (user_id, questions_id)
VALUES
  (1, 1),
  (1, 2),
  (2, 1),
  (2, 2),
  (3, 2);


INSERT INTO
  replies (body, replies_id, user_id, questions_id)
VALUES
  ('Really? You think so?', NULL, 1, 2),
  ('Yes I do think so.', 1, 2, 2);

INSERT INTO
  question_like (user_id, questions_id)
VALUES
  (1, 1),
  (2, 1),
  (3, 1),
  (2, 2);
