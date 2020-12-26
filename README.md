apt install mysql-server-8.0

https://habr.com/ru/post/413155/

https://gist.githubusercontent.com/tleish/1c6e788c84f59200446b/raw/86cdcbc7be74aa884bc7ce4f0208780c483e8cfb/mysql_backup.sh


mysql> CREATE DATABASE mydb;
mysql> use mydb


mysql> CREATE TABLE animals (id MEDIUMINT NOT NULL AUTO_INCREMENT,
creation_time DATETIME DEFAULT CURRENT_TIMESTAMP, 
modification_time DATETIME ON UPDATE CURRENT_TIMESTAMP,
name CHAR(30) NOT NULL, PRIMARY KEY (id));

mysql> INSERT INTO animals (name) VALUES ("sharik"),("tuzik"),("bobik");

SELECT * FROM animals;

mysql> UPDATE animals SET name = 'sharikov' WHERE id = 1;


1) Утановить папку хранения. Если её нет, то создать.

2) Установить время хренения в минутах.

3) Удалять старые backup только после усрешного создания нового.

4) Сделать проверку backups по размеру. *
