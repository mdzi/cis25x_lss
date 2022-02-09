copy /y template-nosan.cnf %1.cnf
ren %1.cnf %1.bak.cnf
cat %1.bak.cnf | sed -e "s/\*DN\*/%1/g" > %1.cnf
notepad %1.cnf
del %1.bak.cnf
openssl req -new -config %1.cnf -keyout %1.key -out %1.req
