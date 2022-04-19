# Sturdy Mongo

Somehow sturdier...
Goal is to launch mongo real fast and, maybe, have to go into production 
with it. And even though, if it had been for production, 
it would have been a very different 
planned install, make it sturdy anyway.

Obstacles to install mongodb properly for production are multiple but, in no specific order:

 - Not enough hosts with independant IP for replica sets.
 - No time for establishing a proper TLS infrastructure. 

How to install mongodb with Sturdy Mongo:
- copy `mongo-root-passwd.example` to `mongo-root-passwd` and edit it with the proper mongodb root password.
- copy `mongo-user-passwd.example` to `mongo-user-passwd` and edit it with the proper mongodb user password.
- Spin up your terminal, git clone this repo, cd into it then run this:
`./create.sh`

