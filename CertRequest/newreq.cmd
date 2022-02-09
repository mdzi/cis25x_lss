copy /y template.cnf %1.cnf
notepad %1.cnf
openssl req -new -config %1.cnf -keyout %1.key -out %1.req
