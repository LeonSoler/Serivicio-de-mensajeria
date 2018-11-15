program serviciodemensajeria;
uses
    sysutils,crt;
type
    arbusuarios=^usuarios;
    usuarios=record
        nombre:string[8];
        password:string[8];
        mayores,menores:arbusuarios;
    end;
    users=record
        nombres:string[8];
        passwords:string[8];
    end;
    tlistamen=^listamen;
    listamen=record
        fecha:string[18];
        mensaje:string;
        leido:boolean;
        usuario:arbusuarios;
        sig:tlistamen;
    end;
    tlista=^listaconvers;
    listaconvers=record
        codigo:integer;
        usuario1,usuario2:arbusuarios;
        sig:tlista;
        puntlista:tlistamen;
    end;
    listaconversaciones=record
        codigo:Integer;
        usuario1,usuario2:string[8];
    end;
    listamensajes=record
        fecha:string[18];
        mensaje:string;
        leido:boolean;
        usuario1:string[8];
        codigoconver:integer;
    end;
    tlistahiper=^listah;
    listah=record
        cantconver:integer;
        remitente:string[8];
        sig:tlistahiper;
    end;
    archivo_usuarios= file of users;
    archivo_Mensajes= file of listamensajes;
    archivo_convers= file of listaconversaciones;
procedure borrarlistamensajes(var lista:tlistamen);
begin
    if (lista<>nil) then 
    begin    
        borrarlistamensajes(lista^.sig);
        dispose(lista);
    end;
end;
procedure borrarconversaciones(var lista:tlista; usuarioborrar:string);
var
    aeliminar:tlista;
begin
    if (lista<>nil) then
        if (lista^.usuario1^.nombre = usuarioborrar) or (lista^.usuario2^.nombre = usuarioborrar) then
            begin
                aeliminar:=lista;
                lista:=aeliminar^.sig;
                borrarlistamensajes(aeliminar^.puntlista);
                dispose(aeliminar);
            end
        else 
            borrarconversaciones(lista^.sig,usuarioborrar);
end;
procedure eliminarnodo(var arb:arbusuarios);
var
    eliminar,menormayores:arbusuarios;
begin
    if (arb^.menores = nil) and (arb^.mayores = nil) then
        begin
            eliminar:=arb;
            arb:=nil;
            dispose(eliminar);
        end
    else
    begin
    if (arb^.menores <> nil) and (arb^.mayores = nil) then 
        begin
            eliminar:=arb;
            arb:=eliminar^.menores;
            dispose(eliminar);
        end;
    if (arb^.menores = nil) and (arb^.mayores <> nil) then
        begin
            eliminar:=arb;
            arb:=eliminar^.mayores;
            dispose(eliminar);
        end;
    if (Arb^.menores<>nil) and (arb^.mayores<>nil) then
        begin
            eliminar:=arb;
            menormayores:=arb^.mayores;
            while menormayores^.menores<> nil do 
            begin 
               menormayores:=menormayores^.menores;
            end;
            menormayores^.mayores:=eliminar^.mayores;
            menormayores^.menores:=eliminar^.menores;
            arb:=menormayores;
            arb^.mayores:=nil;
            dispose(eliminar);
        end;
    end;
end;
procedure borrarusuario(var arb:arbusuarios;usuarioborrar:string; var lista:tlista);
begin
    if (arb<>nil) then
        if (arb^.nombre = usuarioborrar) then
            begin
                borrarconversaciones(lista,usuarioborrar);
                eliminarnodo(arb);
            end
        else 
            if (arb^.nombre < usuarioborrar) then
                borrarusuario(arb^.mayores,usuarioborrar,lista)
            else 
                borrarusuario(arb^.menores,usuarioborrar,lista);
end;
function cantidadconvers(lista:tlista;usuario:string):integer;
var
    cursor:tlista;
    cantidad:integer;
begin
    cursor:=lista;
    cantidad:=0;
    while (cursor<>nil) do 
        begin
            if (cursor^.usuario1^.nombre = usuario) or (cursor^.usuario2^.nombre = usuario) then
                begin
                    cantidad:=cantidad+1;
                    cursor:=cursor^.sig;
                end
            else cursor:=cursor^.sig;
        end;
    cantidadconvers:=cantidad;
end;
procedure insertarordenado(var hiperconectados:tlistahiper;nodo:tlistahiper);
var
    cursor:tlistahiper;
begin   
    if (hiperconectados = nil) then
        hiperconectados:=nodo
    else
        if (hiperconectados^.cantconver < nodo^.cantconver) then
            begin
                nodo^.sig:=hiperconectados;
                hiperconectados:=nodo;
            end
        else begin
                cursor:=hiperconectados;
                while (cursor^.sig<>nil) and (cursor^.sig^.cantconver > nodo^.cantconver) do 
                    cursor:=cursor^.sig;
                if (cursor<>nil) then 
                begin
                    nodo^.sig:=cursor^.sig;
                    cursor^.sig:=nodo;
                end;
            end;
end;
function crearnodohiperconectados(arb:arbusuarios;lista:tlista):tlistahiper;
var
   nodohiper:tlistahiper;
begin
     new(nodohiper);
     nodohiper^.remitente:=arb^.nombre;
     nodohiper^.cantconver:=cantidadconvers(lista,arb^.nombre);
     nodohiper^.sig:=nil;
crearnodohiperconectados:=nodohiper;
end;
procedure imprimirlistahiper(hiperconectados:tlistahiper);
var
    cursor:tlistahiper;
begin
    cursor:=hiperconectados;
    while (cursor<>nil) do 
        begin
            write(cursor^.remitente,' cantidad de conversaciones  ');
            writeln(cursor^.cantconver);
            cursor:=cursor^.sig;
        end;
end;
procedure crearlistahiper(arb: arbusuarios; lista:tlista; var hiperconectados:tlistahiper);
var
    nodo:tlistahiper;
begin
    if (arb <> nil) then
        begin
            nodo:=crearnodohiperconectados(arb,lista);
            insertarordenado(hiperconectados,nodo);
            crearlistahiper(arb^.menores,lista,hiperconectados);
            crearlistahiper(arb^.mayores,lista,hiperconectados);
        end;
end;
procedure verusuarioshiperconectados(arb:arbusuarios;lista:tlista);
var 
    hiperconectados:tlistahiper;
begin
    hiperconectados:=nil;
    crearlistahiper(arb,lista,hiperconectados);
    imprimirlistahiper(hiperconectados);
end;
Function buscarusuario (arb:arbusuarios;nombrel:string):arbusuarios;
begin 
    If (arb=Nil) then begin
        buscarusuario:=nil;
    end
    else begin
            If (arb^.nombre=nombrel) then 
                begin 
                    buscarusuario:=arb;
                end
        else begin
                If (arb^.nombre<nombrel) then 
                    begin
                        buscarUsuario := buscarusuario(arb^.mayores,nombrel)
                    end;
                if (arb^.nombre>nombrel) then
                    buscarusuario := buscarusuario(arb^.menores,Nombrel);
            end;
        end;
end; 
function crearnodoarchconversacion(aux:listaconversaciones; arb:arbusuarios):tlista;
var
    nodo:tlista;
    user:string[8];
begin
    new(nodo);
    nodo^.codigo:=aux.codigo;
    user:=aux.Usuario1;
    nodo^.usuario1:=BuscarUsuario(arb,user);
    user:=aux.usuario2;
    nodo^.usuario2:=buscarusuario(arb,user);
    nodo^.sig:=nil;
crearnodoarchconversacion:=nodo;
end;
procedure insertarordenadoconver(var lista:tlista;nodo:tlista);
begin
    if (lista=nil) then
        lista:=nodo
    else
        insertarordenadoconver(lista^.sig,nodo);
end;
function crearnodomensaje(aux:listamensajes;arb:arbusuarios):tlistamen;//CREA NODO DE ARCHIVO
var
    nodo:tlistamen;
    user:string[8];
begin
    new(nodo);
    nodo^.fecha:=aux.fecha;
    nodo^.mensaje:=aux.mensaje;
    nodo^.leido:=aux.leido;
    user:=aux.usuario1;
    nodo^.usuario:=buscarusuario(arb,user);
    nodo^.sig:=nil;
crearnodomensaje:=nodo;
end;
procedure insertarultimo(var lista:tlistamen;nodo:tlistamen);
begin
    if (lista = nil) then
        lista:=nodo
    else insertarultimo(lista^.sig,nodo);
end;
procedure levantararchivolistamen(var archmen:archivo_mensajes;var lista:tlista;arb:arbusuarios;aux2:listamensajes);
var
nodo:tlistamen;
begin
    while not eof(archmen) and (aux2.codigoconver=lista^.codigo) do
                        begin
                            nodo:=crearnodomensaje(aux2,arb);         
                            insertarultimo(lista^.puntlista,nodo);
                            read(archmen,aux2);
                        end;
end;
procedure Levantararchivolistac(var archconver:archivo_convers; var lista:tlista; arb:arbusuarios);
var
    auxconver:listaconversaciones;
begin
        while not eof(archconver) do 
            begin  
                read(archconver,auxconver);
                insertarordenadoconver(lista,crearnodoarchconversacion(auxconver,arb));
            end;
end;
procedure levantararchivomensajes(var archmen:archivo_mensajes;var lista:tlista; arb:arbusuarios);
var
    cursor:tlista;
    auxmen:listamensajes;
begin
    cursor:=lista;
    if not eof(archmen) then
        read(archmen,auxmen);
    while (cursor<>nil) do 
        begin
            while not eof(archmen) and (auxmen.codigoconver = cursor^.codigo) do 
                        begin
                            insertarultimo(cursor^.puntlista,crearnodomensaje(auxmen,arb));
                            read(archmen,auxmen);
                        end;
            if eof(archmen) and (auxmen.codigoconver = cursor^.codigo) then
                insertarultimo(cursor^.puntlista,crearnodomensaje(auxmen,arb));
            cursor:=cursor^.sig;                
        end;
end;
procedure InsertarListaMenArch(var archmen:archivo_mensajes;lista:tlista);
var
    aux:listaMensajes;
    cursor:tlistamen;
begin
    cursor:=lista^.puntlista;
    while (cursor<> nil) do 
        begin
            aux.fecha:=cursor^.fecha;
            aux.codigoconver:=lista^.codigo;
            aux.mensaje:=cursor^.mensaje;
            Aux.usuario1:=cursor^.usuario^.nombre;
            aux.leido:=cursor^.leido;
            write(archmen,aux);
            cursor:=cursor^.sig;
        end;
end;
procedure insertarlistaconversarch(var archconver:archivo_convers;lista:tlista; var archmen:archivo_mensajes);
var
    aux:listaconversaciones;
    cursor:tlista;
begin
    cursor:=lista;
        while (cursor<>nil) do
        begin
            aux.codigo:=cursor^.Codigo;
            aux.usuario1:=cursor^.usuario1^.nombre;
            aux.usuario2:=cursor^.usuario2^.nombre;
            Write(archconver,aux);
            insertarlistaMenArch(archmen,cursor);
            cursor:=cursor^.sig;
        end;
end;
Function crearnodomen (usuario:arbusuarios;leido:boolean):tlistamen;
var
    cursor:tlistamen;
    mensaje:string;
begin  
    new(cursor);
    cursor^.fecha:=datetimetostr(now);
    writeln('Mensaje');
    readLn(mensaje);
    cursor^.mensaje:=mensaje;
    cursor^.usuario:=usuario;
    cursor^.leido:=leido;
    writeln('Mensaje enviado');
    writeln(cursor^.fecha);
    cursor^.sig:=nil;
    crearnodomen:=cursor;
end;
function existeusuario(arb:arbusuarios;user2:string):boolean;
begin
    if (arb = nil) then
        existeUsuario:=false
    else
        if (Arb^.Nombre = User2) then
             existeusuario:=true
        else
            if (arb^.Nombre < user2) then
                existeusuario := existeusuario(arb^.mayores,user2)
            else
                existeusuario := existeusuario(arb^.menores,user2);
end;
function crearnodoconversacion(codigo:integer;arb:arbusuarios;usuario:arbusuarios;destinatario:arbusuarios):tlista;
var
    nodo:tlista;
begin
    new(nodo);
    nodo^.codigo:=codigo+1;
    nodo^.usuario1:=usuario;
    nodo^.usuario2:=destinatario;
    nodo^.puntlista:=nil;
    nodo^.sig:=nil;
    crearnodoconversacion:=nodo;
end;
function yatieneconver(lista:tlista;usuario2:string;remitente:string):boolean;
var
    cursor:tlista;
    tiene:boolean;
begin
    tiene:=false;
    cursor:=lista;
    while (cursor<>nil) and (tiene=false) do 
        begin 
            if (cursor^.usuario1^.nombre = remitente) or (cursor^.usuario2^.nombre = remitente) then
                if (cursor^.usuario1^.nombre = usuario2) or (cursor^.usuario2^.nombre = usuario2) then
                    tiene:= true
                else
                    cursor:=cursor^.sig
            else cursor:=cursor^.sig;
        end;
yatieneconver:=tiene;
end;
procedure crearlistaconver(var lista:tlista;codigo:integer;usuario:arbusuarios;leido:boolean;usuario2:string;arb:arbusuarios);
var
    nuevomensaje:tlistamen;
begin
    if (lista=nil) then 
        begin
            lista:=crearnodoconversacion(codigo,arb,usuario,buscarusuario(arb,usuario2));
            nuevomensaje:=crearnodomen(usuario,leido);
            nuevomensaje^.sig:=lista^.puntlista;
            lista^.puntlista:=nuevomensaje;
        end
    else crearlistaconver(lista^.sig,codigo,usuario,leido,usuario2,arb);
end;
procedure nuevaconversacion(var lista:tlista;Codigo:integer;arb:arbusuarios;usuario:arbusuarios;leido:boolean);
var
    usuario2:string[8];
begin
    writeln('Enviar a');
    readln(usuario2);
    if (buscarusuario(arb,usuario2)<>nil)  then
        if yatieneconver(lista,usuario2,usuario^.nombre)=true then
            Writeln('Ya tiene una conversacion activa')
        else
            begin
                crearlistaconver(lista,codigo,usuario,leido,usuario2,arb);
                writeln('Su codigo de conversacion es: ',codigo+1);
            end
    else
        Writeln('El usuario no existe');
end;
function cantidadmsj(lista:tlista):integer;
var
    cursor:tlistamen;
    i:integer;
begin
    i:=0;
    cursor:=lista^.puntlista;
    while (cursor <>nil) do
        begin
            i:=i+1;
            cursor:=cursor^.sig;
        end;
cantidadmsj:=i;
end;
Procedure Imprimirlistamen(lista:tlistamen;maxmensajes,i:integer);
begin
    if (lista <>Nil) and (i<=maxmensajes) then 
        begin
            imprimirlistamen(lista^.sig,maxmensajes,i+1);
            writeln(lista^.usuario^.nombre,':',lista^.mensaje);
            writeln(lista^.fecha);
            if lista^.leido =true then
                writeln('Leido')
            else
                writeln('No Leido');
        end;
end;
Procedure ImprimirlistaC(lista:tlista);
begin
    If lista<>Nil then begin
        WriteLn(Lista^.Codigo);
        imprimirlistaC(lista^.sig);
    end;
end;
procedure insertararchivo(var arch:archivo_usuarios;arb:arbusuarios);
var
    aux:users;
begin
    if (arb <> nil) then 
        begin
            aux.nombres:=arb^.nombre;
            aux.passwords:=arb^.password;
            write(arch,aux);
            insertararchivo(arch,arb^.menores);
            insertararchivo(arch,arb^.mayores);
        end;
end;
Procedure insertarnodo(var arb:arbusuarios;aux:arbusuarios);
begin
    If (arb=nil) then
        arb:=aux
    else
        If  (arb^.nombre)<=(aux^.nombre) then
                insertarNodo(arb^.mayores,aux)
        else   insertarnodo(arb^.menores,aux);
end;
function nuevonodo(usuario:string;password:string):arbusuarios;
var
    nodo:arbusuarios;
begin
    new(nodo);
    nodo^.nombre:=usuario;
    nodo^.password:=password;
    nodo^.Mayores:=nil;
    nodo^.Menores:=nil;
    nuevonodo:=nodo;
end;
procedure levantararchivo(var arch:archivo_usuarios; var arb:arbusuarios);
var
    aux:users;
    aux2:arbusuarios;
begin
    while not eof(arch) do 
        begin
            read(arch,aux);
            new(aux2);
            aux2^.nombre:=aux.nombres;
            aux2^.password:=aux.passwords;
            aux2^.mayores:=nil;
            aux2^.menores:=nil;
            insertarnodo(arb,aux2);
        end;
end;
Procedure nuevousuario(var arb:arbusuarios);
var
    selector:integer;
    nuevo:arbusuarios;
    usuario,password:string[8];
begin
    selector:=3;
    writeln('Desea crear un usuario');
    writeln('1:=SI');
    writeln('2:=NO');
    while ((selector <> 1) and (selector <> 2)) do
        readln(selector);
            if selector=1 then 
                begin
                    clrscr;
                    readln(usuario);
                    if existeusuario(arb,usuario) = false then
                        begin
                            readln(password);
                            nuevo:=nuevonodo(usuario,password);
                            insertarnodo(arb,nuevo); 
                            writeLn('REGISTRO EXITOSO');
                        end
                    else
                        writeln('El nombre de usuario ya existe');
                end;
            if selector=2 then
                clrscr;
end;
procedure contestarmensaje(var lista:tlista;usuario:arbusuarios;leido:boolean);
var
    codigoconver,maxmensajes,i:integer;
    cursor:tlista;
    cursor2:tlistamen;
    nodocontestar:tlistamen;
begin
    cursor:=lista;
    Writeln('Ingrese el codigo de conversacion:');
    Readln(codigoconver);
    i:=1;
    maxmensajes:=5;
    while (cursor<>nil) and (codigoconver <> cursor^.codigo) do
        cursor:=cursor^.sig;
    if cursor=nil then
        Writeln('El codigo no existe')
    else
        if (cursor^.usuario1^.nombre= usuario^.nombre) or (cursor^.usuario2^.nombre= usuario^.nombre) then
            begin
                Writeln('Ultimos 5 mensajes');
                cursor2:=cursor^.puntlista;
                imprimirlistamen(cursor^.puntlista,maxmensajes,i);
                while (cursor2<>nil) and (cursor2^.usuario <> usuario) do 
                    begin
                        cursor2^.leido:=true;
                        cursor2:=cursor2^.sig;
                    end;
                        nodocontestar:=Crearnodomen(usuario,leido);
                        nodocontestar^.sig:=cursor^.puntlista;
                        cursor^.puntlista:=nodocontestar;
            end
        else
            writeln('No pertenece a esta conversacion');
end;
procedure actualizarleido(var lista:tlistamen;usuario:arbusuarios);
var
    cursor:tlistamen;
begin
    cursor:=lista;
    while (cursor<>nil) do
        begin
            if (cursor^.usuario <> usuario) then
                cursor^.leido:=true;
            cursor:=cursor^.sig;
        end;
end;
procedure verconversacion(var lista:tlista;usuario:arbusuarios;min,max:integer);
var
    codigoconver:integer;
    cursor:tlista;
    cursor2:tlista;
begin
    cursor:=lista;
    Writeln('Ingrese el codigo de conversacion:');
    Readln(codigoconver);
    clrscr;
    while  (cursor <> nil) and (codigoconver <> cursor^.codigo) do
        cursor:=cursor^.sig;
    if cursor=nil then
        Writeln('El codigo no existe')
    else
        if (cursor^.usuario1^.nombre= usuario^.nombre) or (cursor^.usuario2^.nombre= usuario^.nombre) then
            begin
                if (cursor<>nil) then
                    begin
                        cursor2:=cursor;
                        Writeln('Conversacion completa');
                        actualizarleido(cursor^.puntlista,usuario);
                        if (cursor2^.puntlista <> nil) then 
                            imprimirlistamen(cursor2^.puntlista,max,min);
                    end
                else
                    writeln('No se ha encontrado la conversacion');
            end
        else
            Writeln('No pertenece a la conversacion');
end;
function cantidadmsjnoleidos(lista:tlistamen;usuario:arbusuarios):integer;
var
    i:integer;
begin
    i:=0;
    while (lista <>nil) do
        begin
            if (lista^.leido =false) and (lista^.usuario<>usuario) then
                i:=i+1;
                lista:=lista^.sig;
        end;
cantidadmsjnoleidos:=i;
end;
function cantidadtotalmsjnoleidos(lista:tlista;usuario:arbusuarios):integer;
var
    i:integer;
begin
    i:=0;
    while (lista <> nil) do
        begin
            if (lista^.usuario1^.nombre=usuario^.nombre) or (lista^.usuario2^.nombre=usuario^.nombre) then
                begin
                    i:=i+cantidadmsjnoleidos(lista^.puntlista,usuario);
                end;
            lista:=lista^.sig
        end;
    cantidadtotalmsjnoleidos:=i;
end;
procedure imprimirconversact(lista:tlista;usuario:arbusuarios);
var
    cursor:tlista;
begin
    cursor:=lista;
    while (cursor <> nil) do
        begin
            if (cursor^.usuario1^.nombre = usuario^.nombre) or (cursor^.usuario2^.nombre = usuario^.nombre) then
                begin
                    if cursor^.usuario1^.nombre=usuario^.nombre then
                        write(cursor^.usuario2^.nombre)
                    else
                        write(cursor^.usuario1^.nombre);
                    write(' codigo: ',cursor^.codigo);
                    write(' cantidad msj no leidos: ');
                    writeln(cantidadmsjnoleidos(cursor^.puntlista,usuario));
                end;
            cursor:=cursor^.sig;
        end;
end;
procedure listartodasconvers(lista:tlista;usuario:arbusuarios);
var
    cursor:tlista;
begin
    cursor:=lista;
    while (cursor <> nil) do
        begin
            if (cursor^.usuario1^.nombre = usuario^.nombre) or (cursor^.usuario2^.nombre = usuario^.nombre) then
                begin
                    if cursor^.usuario1^.nombre=usuario^.nombre then
                        write(cursor^.usuario2^.nombre)
                    else
                        write(cursor^.usuario1^.nombre);
                    writeln(' codigo: ',cursor^.codigo);
                    
                end;
            cursor:=cursor^.sig;
        end;
end;
Procedure Menu2(Usuario:Arbusuarios;Arb:Arbusuarios;var Lista:Tlista; var codigo:integer);
var
    Opcion:Integer;
    Condicion:Boolean;
    volver,cantmen,cantconver:integer;
    cursor:tlista;
    leido:boolean;
begin
    leido:=false;
    Condicion:=True;
    opcion:=1;
    While (Opcion<8) and (Condicion=True) and (Opcion>0) do begin
    cursor:=lista;
    cantmen:=cantidadtotalmsjnoleidos(cursor,usuario);
    if lista = nil then begin
        cantconver:=0;
        cantmen:=0;
        codigo:=0;
        end
    else begin
        while cursor^.sig <> nil do
            begin
                cursor:=cursor^.sig;
            end;
            
        codigo:=cursor^.codigo;
        cantconver:=cantidadconvers(lista,usuario^.nombre);
        end;
    writeLn('USUARIO: ', usuario^.nombre,' - ',cantmen,' MSJ NO LEIDOS',' - ',cantconver,' CONVERS ACT');
    writeLn('1_Listar conversaciones activas');
    writeLn('2_Listar todas las conversaciones');
    writeLn('3_Ver ultimos mensajes de conversacion');
    writeLn('4_Ver conversacion');
    writeLn('5_Contestar mensaje');
    writeLn('6_Nueva conversacion');
    writeLn('7_Borrar usuario');
    writeLn('8_Logout');
    readLn(opcion);
            If (opcion = 1) then 
                begin
                    clrscr;
                    if (lista <> nil) then
                        imprimirconversact(lista,usuario)
                    else
                        writeln('No existen conversaciones');
                    writeln('Presione 1 para volver al menu');
                    readln(volver);
                end;
            if (opcion = 2) then 
                begin
                    clrscr;
                    if (lista <> nil) then
                        listartodasconvers(lista,usuario)
                    else
                        writeln('No existen conversaciones');
                    writeln('Presione 1 para volver al menu');
                    readln(volver);
                end;
            if (opcion = 3) then
                begin
                    clrscr;
                    if (lista <> nil) then
                    verconversacion(lista,usuario,1,10)
                    else
                        writeln('No existen conversaciones');
                    writeln('Presione 1 para volver al menu');
                    readln(volver);
                end;
            if (opcion = 4) then 
                begin
                    clrscr;
                    if (lista <> nil) then
                        verconversacion(lista,usuario,1,cantidadmsj(lista))
                    else
                        writeln('No existen conversaciones');
                    writeln('Presione 1 para volver al menu');
                    readln(volver);
                end;
            if (opcion = 5) then 
                begin
                    clrscr;
                    if lista=nil then
                        writeln('No existen conversaciones')
                    else
                        contestarmensaje(lista,usuario,leido);
                    writeln('Presione 1 para volver al menu');
                    readln(volver);
                end;
            if (opcion = 6) then 
                begin
                    clrscr;
                    nuevaconversacion(lista,codigo,arb,usuario,leido);
                    writeln('Presione 1 para volver al menu');
                    readln(volver);
                    if (volver = 1) then 
                    condicion:=true;
                end;
            if (opcion = 7) then 
            begin
                clrscr;
                borrarusuario(arb,usuario^.nombre,lista);
                    writeln('Presione 1 para volver al menu');
                    readln(volver);
                    if (volver = 1) then 
                    condicion:=false;
            end;
            clrscr;
        end;
end;
function login (arb:arbusuarios;nombrel,passwordl:string):arbusuarios;
var
    usuario:arbusuarios;
    i:integer;
begin
    i:=3;
    writeln('Ingrese su usuario');
    readln(nombrel);
    while (existeusuario(arb,nombrel)= false) and (i>0) do
        begin
            write('Tiene ');
            write(i);
            writeln(' oportunidades para ingresar el usuario correcto');
            Readln(nombreL);
            existeusuario(arb,nombrel);
            i:=i-1;
        end;
    if existeusuario(arb,nombrel)= true then
        begin
            i:=3;
            usuario:=buscarusuario(Arb,NombreL);
            readln(passwordl);
            writeln('Ingrese su contraseña');
            while (PasswordL<>Usuario^.Password) and (i>0) do 
                begin
                    Write('Tiene ');
                    write(i);
                    writeln(' oportunidades para ingresar la contraseña correcta');
                    readln(passwordl);
                    i:=i-1;
                end;
            if passwordl=usuario^.password then
                login:=usuario
            else
                login:=nil;
        end
    else
        login:=nil;
end;
procedure cerrararchivos(var arch:archivo_usuarios; var archmen:archivo_mensajes;var archconver:archivo_convers;arb:arbusuarios;lista:tlista);
begin
    rewrite(arch);
    rewrite(archmen);
    rewrite(archconver);
    insertararchivo(arch,arb);
    insertarlistaconversarch(archconver,lista,archmen);
    close(arch);
    close(archmen);
    close(archconver);
end;
procedure Menu1(Var Arch:Archivo_Usuarios;Var Arb:ArbUsuarios;var archmen:archivo_mensajes;var lista:tlista;var archconver:archivo_convers);
var
    salida:boolean;
    opcion,volver:integer;
    codigo:integer;
    usuario:arbusuarios;
    nombrel,passwordl:string[8];
begin
    salida:=true;
    opcion:=1;
    nombrel:=('a');
    passwordl:=('a');
        While (opcion<4) and (Salida=True) and (Opcion>0) or (Opcion=8) do begin
            Writeln('SERVICIO DE MENSAJERIA');
            Writeln();
            writeln('1_Login');
            writeln('2_Nuevo usuario');
            writeln('3_Ver usuarios hiperconectados');
            writeln('4_Salir');
            writeln();
            readln(opcion);
                begin
                    if (opcion = 1) then
                        begin
                            Clrscr;
                            usuario:=login(arb,nombrel,passwordl);
                            if (usuario <> nil) then
                                begin
                                    clrscr;
                                    menu2(usuario,arb,lista,codigo);
                                end
                            else
                                begin
                                    writeln('Cree su usuario');
                                    opcion:=2;
                                end;
                        end;
                    if (opcion = 2) then 
                        begin
                            Clrscr;
                            nuevousuario(arb);
                            salida:=false;
                            writeln('Presione 1 para volver al menu principal');
                            readln(volver);
                            if (volver = 1) then 
                                begin
                                    salida:=true;
                                    clrscr;
                                end;
                        end;
                    if (opcion = 3) then
                        begin
                            clrscr;
                            verusuarioshiperconectados(arb, lista);
                            salida:=false;
                            writeln('Presione 1 para volver al menu principal');
                            readln(Volver);
                            if (volver = 1) then 
                            begin
                                Salida:=True;
                                Clrscr;
                            end;
                        end;
                    if (opcion = 4) then
                    begin
                    end;
                end;
           end;
end;
procedure abrirarchivoconver(var archconver:archivo_convers);
begin
    {$I-}
    reset(archconver);
    {$I+}
    if (IOresult <> 0) then
        rewrite(archconver);
end;
procedure abrirarchivomen(var archmen:archivo_mensajes);
begin
    {$I-}
    reset(archmen);
    {$I+}
    if (IOresult <> 0) then
        rewrite(archmen);
end;
procedure abrirarchivoarb(var arch:archivo_usuarios);
begin
    {$I-}
    reset(arch);
    {$I+}
    if (IOresult <> 0) then
        rewrite(arch);
end;
procedure inicializararchivos(var arch:archivo_usuarios;var arb:arbusuarios; var archmen:archivo_mensajes;var archconver:archivo_convers;var lista:tlista);
begin
    assign(arch,'/ip2/EntregaPelizzaSoler');
    abrirarchivoarb(arch);
    assign(archconver,'/ip2/EntregaPelizzaSolerCon');
    abrirarchivoconver(Archconver);
    assign(archMen,'/ip2/EntregaPelizzaSolerMen');
    abrirarchivomen(ArchMen);
    arb:=nil;
    lista:=nil;
    levantarArchivo(arch,arb);
    levantarArchivoListaC(archconver,lista,arb);
    levantararchivomensajes(archmen,lista,arb)
end;
var
    archmen:archivo_mensajes;
    arch:archivo_usuarios;
    archconver:archivo_convers;
    arb:arbusuarios;
    lista:tlista;
begin
    inicializararchivos(arch,arb,archmen,archconver,lista);
    menu1(arch,arb,archmen,lista,archconver);
    cerrararchivos(arch,archmen,archconver,arb,lista);
end.