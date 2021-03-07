/*
 * AnarQ main SQL scheme.
 */
drop database anarq;
create database anarq;
use anarq;


/*
 * Topic posts belongs to.
 */
create table topics (
  name varchar(25) not null,
  description varchar(2048) null,
  primary key (name)
);


/*
 * Visibility for posts.
 */
create table visibility (
  name varchar(25) not null,
  description varchar(2048) null,
  primary key (name)
);

insert into visibility (name, description) values ('public', 'Publicly visible post, implying anyone can see it');
insert into visibility (name, description) values ('protected', 'Protected post, implying only authenticated and authorised users can see it');


/*
 * Actual table for posts.
 */
create table posts (
  id int(8) not null auto_increment,
  content text not null,
  created datetime not null default current_timestamp,
  user varchar(256) not null,
  topic varchar(25) not null,
  visibility varchar(25) not null,
  path varchar(2048) not null,
  unique index idx_created (created),
  unique index idx_user (user),
  unique index idx_topic (topic),
  unique index idx_path (path),
  primary key (id)
);


/*
 * Likes for posts.
 */
create table likes (
  post_id int(8) not null,
  user varchar(256) not null,
  primary key (post_id, user)
);


/*
 * Adding referential integrity for posts pointing towards topics and visibility.
 */
alter table posts add foreign key(topic) references topics(name) on delete cascade on update cascade;
alter table posts add foreign key(visibility) references visibility(name) on delete cascade on update cascade;


/*
 * Adding referential integrity for likes pointing towards posts.
 */
alter table likes add foreign key(post_id) references posts(id) on delete cascade on update cascade;
