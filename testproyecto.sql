create database mesaregalos2;
use mesaregalos2;
#drop database mesaregalos2;

create table invitados (
idInv int primary key auto_increment,
nomInv varchar(30)
)engine=innodb;

create table articulos (
idArt int primary key auto_increment,
precArt decimal (10,2),
existArt int
)engine=innodb;

create table clientes (
idCli int primary key auto_increment,
nomCli varchar(30),
dirCli varchar(30)
);

create table listas (
idLista int primary key auto_increment,
idCli int,
foreign key (idCli) references clientes (idCli) on delete cascade on update cascade
)engine=innodb;

create table regalos (
idReg int primary key auto_increment,
idArt int,
estadoReg varchar(12),
idLista int,
foreign key (idArt) references articulos (idArt) on delete cascade on update cascade,
foreign key (idLista) references listas (idLista) on delete cascade on update cascade
)engine=innodb;

create table detalle_regalos (
idReg int,
idInv int,
mensaje varchar (200),
foreign key (idReg) references regalos (idReg) on delete cascade on update cascade,
foreign key (idInv) references invitados (idInv) on delete cascade on update cascade
)engine=innodb;

create table eventos (
idEv int primary key auto_increment,
nomEv varchar(30),
idLista int,
fecha date,
tipoEv varchar(30),
tipoDet varchar(30),
descripDet varchar(30),
foreign key (idLista) references listas (idLista) on update cascade on delete cascade
)engine=innodb;

-- Uso de procedimentos almacenados o triggers para la base de datos 
-- trigger para agregar articulos 
ALTER TABLE articulos ADD fechaAgregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
DELIMITER //
CREATE TRIGGER after_insert_articulos
AFTER INSERT ON articulos
FOR EACH ROW
BEGIN
    -- Actualiza la fecha del artiuclo agregado al momento de la inserción
    UPDATE articulos SET fechaAgregado = NOW() WHERE idArt = NEW.idArt;
END 
//
INSERT INTO articulos (precArt, existArt) VALUES (19.99, 150);
-- trigger para la creacion de mesas 
DELIMITER //
CREATE TRIGGER before_insert_eventos
BEFORE INSERT ON eventos
FOR EACH ROW
BEGIN
    -- Verificar el valor de tipoEv y actualizar tipoDet con su respectivo tema
    IF NEW.tipoEv = 'Boda' THEN SET NEW.tipoDet = 'Contrayente';
    ELSEIF NEW.tipoEv = 'XV' THEN SET NEW.tipoDet = 'Tema';
    ELSEIF NEW.tipoEv = 'Nacimientos' THEN SET NEW.tipoDet = 'Color';
    END IF;
END 
//
INSERT INTO eventos (nomEv, idLista, fecha, tipoEv) VALUES ('Fiesta de XV', 1, '2023-11-15', 'XV');
INSERT INTO eventos (nomEv, idLista, fecha, tipoEv) VALUES ('Nacimiento de Sofía', 1, '2023-10-10', 'Nacimientos');
-- 4.- Listar la sucursal y los regalos que están seleccionados para un evento en particular.
DELIMITER //
CREATE PROCEDURE ListarRegalosPorEvento(IN eventoId INT)
BEGIN
    SELECT r.idReg AS IdRegalo, r.estadoReg AS EstadoRegalo, a.idArt AS IdArticulo, a.precArt AS PrecioArticulo, dr.mensaje AS MensajeInvitado
    FROM regalos r JOIN eventos e ON r.idLista = e.idLista
    JOIN articulos a ON r.idArt = a.idArt
    LEFT JOIN detalle_regalos dr ON r.idReg = dr.idReg
    WHERE e.idEv = eventoId
    ORDER BY r.idReg;
END 
//
-- 5.- Listar el nombre del invitado y el regalo que selecciono para un evento en particular.
DELIMITER //
CREATE PROCEDURE listar_invitados_y_regalos(IN p_idEv INT)
BEGIN
    SELECT i.nomInv AS Nombre_Invitado, a.idArt AS ID_Articulo, r.estadoReg AS Estado_Regalo FROM detalle_regalos dr JOIN regalos r ON dr.idReg = r.idReg
    JOIN eventos e ON r.idLista = e.idLista
    JOIN invitados i ON dr.idInv = i.idInv
    JOIN articulos a ON r.idArt = a.idArt
    WHERE e.idEv = p_idEv;
END 
//
CALL listar_invitados_y_regalos(/*id*/); 
-- 6.- Listar el cliente y regalos e invitados que acudirán a su evento.
DELIMITER //
CREATE PROCEDURE listar_cliente_regalos_invitados(IN p_idCli INT)
BEGIN
    SELECT c.nomCli AS Nombre_Cliente, e.nomEv AS Nombre_Evento, i.nomInv AS Nombre_Invitado, a.idArt AS ID_Articulo, r.estadoReg AS Estado_Regalo
    FROM clientes c JOIN listas l ON c.idCli = l.idCli
    JOIN regalos r ON l.idLista = r.idLista
    JOIN detalle_regalos dr ON r.idReg = dr.idReg
    JOIN eventos e ON l.idLista = e.idLista
    JOIN invitados i ON dr.idInv = i.idInv
    JOIN articulos a ON r.idArt = a.idArt
    WHERE c.idCli = p_idCli;
END 
//
CALL listar_cliente_regalos_invitados(/*id*/); 
-- 7.- Listar los eventos donde las ventas por sus regalos sobrepasa los $5000.00
DELIMITER //
CREATE PROCEDURE listar_eventos_con_ventas_altas()
BEGIN
    SELECT e.idEv AS ID_Evento, e.nomEv AS Nombre_Evento, SUM(a.precArt) AS Total_Ventas
    FROM eventos e JOIN listas l ON e.idLista = l.idLista
    JOIN regalos r ON l.idLista = r.idLista
    JOIN articulos a ON r.idArt = a.idArt
    GROUP BY e.idEv, e.nomEv
    HAVING Total_Ventas > 5000.00;
END 
//
CALL listar_eventos_con_ventas_altas();
-- 8-. Listar los clientes que han si acreedores de $1000.00. como bono de regalo por su mesa de regalos.
DELIMITER //
CREATE PROCEDURE listar_clientes_con_bono_regalo()
BEGIN
    SELECT c.idCli AS ID_Cliente, c.nomCli AS Nombre_Cliente, SUM(a.precArt) AS Total_Ventas
    FROM clientes c JOIN listas l ON c.idCli = l.idCli
    JOIN regalos r ON l.idLista = r.idLista
    JOIN articulos a ON r.idArt = a.idArt
    GROUP BY c.idCli, c.nomCli
    HAVING Total_Ventas > 1000.00;
END 
//
CALL listar_clientes_con_bono_regalo();
-- 9.- Listar los productos o inventario de cada una de las sucursales.
DELIMITER //
CREATE PROCEDURE ListarProductosDisponibles()
BEGIN
    SELECT idArt, precArt AS Precio, existArt AS Existencia
    FROM articulos
    WHERE existArt > 0
    ORDER BY idArt;
END 
//
CALL ListarProductosDisponibles(); 
-- 10.- Listar el cliente, invitado y regalos por evento.
DELIMITER //
CREATE PROCEDURE ListarClientesInvitadosRegalosPorEvento()
BEGIN
    SELECT c.nomCli AS NombreCliente, i.nomInv AS NombreInvitado, r.idReg AS IdRegalo, e.nomEv AS NombreEvento, r.estadoReg AS EstadoRegalo
    FROM eventos e JOIN listas l ON e.idLista = l.idLista
    JOIN clientes c ON l.idCli = c.idCli
    LEFT JOIN egalos r ON e.idLista = r.idLista
    LEFT JOIN detalle_regalos dr ON r.idReg = dr.idReg
    LEFT JOIN invitados i ON dr.idInv = i.idInv
    ORDER BY e.nomEv, c.nomCli, i.nomInv;
END 
//
CALL ListarClientesInvitadosRegalosPorEvento();