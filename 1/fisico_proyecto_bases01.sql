CREATE DATABASE banco_micolchon
PRINT 'BASE DE DATOS banco_micolchon CREADA'
GO

USE banco_micolchon
GO

CREATE TABLE catalogo_generico(
	id_catalogo_generico INT IDENTITY(1,1),
	categoria NVARCHAR(200) NOT NULL,
	valor NVARCHAR(200) NOT NULL,
	activo BIT NOT NULL DEFAULT 1

	CONSTRAINT PK_CATALOGO_GENERICO PRIMARY KEY (id_catalogo_generico),
	CONSTRAINT CH_CATALOGO_GENERICO_CATEGORIA CHECK(LEN(categoria) > 0),
	CONSTRAINT CH_CATALOGO_GENERICO_VALOR CHECK(LEN(valor) > 0),
	CONSTRAINT UK_CATALOGO_GENERICO_CATEGORIA_VALOR UNIQUE (categoria,valor)
)
PRINT 'TABLA catalogo_generico CREADA'
GO

CREATE TABLE departamento (
	id_departamento INT IDENTITY(1,1),
	nombre NVARCHAR(25) NOT NULL,
	
	CONSTRAINT PK_DEPARTAMENTO_DEPARTAMENTO PRIMARY KEY (id_departamento),
	CONSTRAINT CH_DEPARTAMENTO_NOMBRE CHECK (LEN(nombre) > 4 ),
	CONSTRAINT UK_DEPARTAMENTO_NOMBRE UNIQUE (nombre)
)
PRINT 'TABLA departamento CREADA'
GO

CREATE TABLE municipio (
	id_municipio INT IDENTITY(1, 1),
	id_departamento INT NOT NULL,
	nombre NVARCHAR(50) NOT NULL,

	CONSTRAINT PK_MUNICIPIO_MUNICIPIO PRIMARY KEY (id_municipio),
	CONSTRAINT FK_MUNICIPIO_DEPARTAMENTO FOREIGN KEY (id_departamento) REFERENCES departamento(id_departamento),
	CONSTRAINT CH_MUNICIPIO_NOMBRE CHECK(LEN(nombre) > 5),
	CONSTRAINT UK_MUNICIPIO_DEPARTAMENTO_NOMBRE UNIQUE(id_departamento,nombre)
)
PRINT 'TABLA municipio CREADA'
GO

CREATE TABLE direccion (
	id_direccion INT IDENTITY(1,1),
	direccion_completa NVARCHAR(300) NOT NULL,
	lugar_residencia NVARCHAR(75) NOT NULL,
	indicaciones NVARCHAR(250) NULL,
	id_municipio INT NOT NULL,
	buzon NVARCHAR(10) NULL,

	CONSTRAINT PK_DIRECCION_DIRECCION PRIMARY KEY (id_direccion),
	CONSTRAINT CH_DIRECCION_DIRECCION_COMPLETA CHECK(len(direccion_completa) > 20),
	CONSTRAINT FK_DIRECCION_MUNICIPIO FOREIGN KEY (id_municipio) REFERENCES municipio(id_municipio)
)
PRINT 'TABLA direccion CREADA'
GO

CREATE TABLE cliente (
	id_cliente INT IDENTITY(1,1),
	dpi VARCHAR(13) NOT NULL,
	nombre1 NVARCHAR (30) NOT NULL,
	nombre2 NVARCHAR (30),
	apellido1 NVARCHAR (30) NOT NULL,
	apellido2 NVARCHAR (30),
	fecha_nacimiento date NOT NULL,
	genero BIT NOT NULL, -- 0 = hombre, 1 = mujer
	id_direccion INT NOT NULL,
	
	CONSTRAINT PK_CLIENTE_CLIENTE PRIMARY KEY (id_cliente),
	CONSTRAINT CH_CLIENTE_DPI CHECK (ISNUMERIC(dpi) = 1),
	CONSTRAINT CH_CLIENTE_FECHA CHECK(DATEDIFF(YEAR,fecha_nacimiento,GETDATE()) >= 18),
	CONSTRAINT CH_CLIENTE_NOMBRE1 CHECK(LEN(nombre1) > 0),
	CONSTRAINT CH_CLIENTE_NOMBRE2 CHECK(LEN(nombre2) > 0),
	CONSTRAINT CH_CLIENTE_APELLIDO1 CHECK(LEN(apellido1) > 0),
	CONSTRAINT CH_CLIENTE_APELLIDO2 CHECK(LEN(apellido2) > 0),
	CONSTRAINT FK_CLIENTE_DIRECCION FOREIGN KEY (id_direccion) REFERENCES direccion(id_direccion),
	CONSTRAINT UK_CLIENTE_DPI UNIQUE (dpi),
)
PRINT 'TABLA cliente CREADA'
GO

CREATE TABLE agencia
(
	id_agencia INT IDENTITY(1,1),
	id_direccion INT NOT NULL,
	nombre NVARCHAR(50) NOT NULL,

	CONSTRAINT PK_AGENCIA_AGENCIA PRIMARY KEY (id_agencia),
	CONSTRAINT FK_AGENCIA_DIRECCION FOREIGN KEY (id_direccion) REFERENCES direccion(id_direccion),
	CONSTRAINT UK_AGENCIA_NOMBRE UNIQUE(nombre),
	CONSTRAINT UK_AGENCIA_DIRECCION UNIQUE(id_direccion)
)
PRINT 'TABLA agencia CREADA'
GO

CREATE TABLE comercio
(
	id_comercio INT IDENTITY(1,1),
	id_direccion INT NOT NULL,
	nombre NVARCHAR(50) NOT NULL,

	CONSTRAINT PK_COMERCIO_AGENCIA PRIMARY KEY (id_comercio),
	CONSTRAINT FK_COMERCIO_DIRECCION FOREIGN KEY (id_direccion) REFERENCES direccion(id_direccion),
	CONSTRAINT UK_COMERCIO_NOMBRE UNIQUE(nombre)
)
PRINT 'TABLA comercio CREADA'
GO

CREATE TABLE tarjeta(
	id_tarjeta INT IDENTITY (1,1),
	id_cliente INT NOT NULL,
	--emisor VARCHAR(20) NOT NULL,
	id_emisor INT NOT NULL,

	CONSTRAINT PK_TARJETA_TARJETA PRIMARY KEY (id_tarjeta),
	CONSTRAINT FK_TARJETA_CLIENTE FOREIGN KEY (id_tarjeta) REFERENCES cliente(id_cliente),
	--CONSTRAINT CH_TARJETA_EMISOR CHECK(emisor = 'MasterCard' or emisor = 'VISA' or emisor = 'American Express')
	CONSTRAINT FK_TARJETA_CATALOGO FOREIGN KEY (id_emisor) REFERENCES catalogo_generico(id_catalogo_generico)
)
PRINT 'TABLA tarjeta CREADA'
GO

CREATE TABLE pos(
	id_pos INT NOT NULL,
	id_comercio INT NOT NULL,

	CONSTRAINT PK_POS_POS PRIMARY KEY (id_POS),
	CONSTRAINT FK_POS_COMERCIO FOREIGN KEY (id_comercio) REFERENCES comercio(id_comercio)
)
PRINT 'TABLA pos CREADA'
GO

CREATE TABLE pago(
	id_pago INT NOT NULL,
	id_pos INT NOT NULL,
	id_tarjeta INT NOT NULL,
	descripcion NVARCHAR(50) NOT NULL,

	CONSTRAINT PK_PAGO_PAGO PRIMARY KEY (id_pago),
	CONSTRAINT FK_PAGO_POS FOREIGN KEY (id_POS) REFERENCES POS(id_POS),
	CONSTRAINT FK_PAGO_TARJETA FOREIGN KEY (id_tarjeta) REFERENCES TARJETA(id_tarjeta),
	CONSTRAINT CH_PAGO_DESCRIPCION CHECK(LEN(descripcion) > 0)
)
PRINT 'TABLA pago CREADA'
GO

CREATE TABLE cuenta(
	id_cuenta INT IDENTITY (1,1),
	--tipo VARCHAR(10) NOT NULL,
	id_tipo INT NOT NULL,
	--moneda NCHAR NOT NULL,
	id_moneda INT NOT NULL,
	fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
	capital_disp DECIMAL NOT NULL,
	--id_cliente INT NOT NULL,
	id_agencia INT NOT NULL,

	CONSTRAINT PK_CUENTA_CUENTA PRIMARY KEY (id_cuenta),
	--CONSTRAINT FK_CUENTA_CLIENTE FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
	--CONSTRAINT CH_CUENTA_TIPO CHECK(tipo = 'Ahorro' or tipo = 'Monetaria'),
	CONSTRAINT FK_CUENTA_TIPO FOREIGN KEY (id_tipo) REFERENCES catalogo_generico(id_catalogo_generico),
	--CONSTRAINT CH_CUENTA_MONEDA CHECK(moneda = 'Q' or moneda = '$' or moneda = '€')
	CONSTRAINT FK_CUENTA_MONEDA FOREIGN KEY (id_moneda) REFERENCES catalogo_generico(id_catalogo_generico),
	CONSTRAINT FK_CUENTA_AGENCIA FOREIGN KEY (id_agencia) REFERENCES agencia(id_agencia)
)
PRINT 'TABLA cuenta CREADA'
GO

CREATE TABLE cheque(
	id_cheque INT NOT NULL,
	num_cheque VARCHAR(15) NOT NULL,
	id_cuenta_destino INT NOT NULL,
	id_banco INT NOT NULL,
	cuenta_externa VARCHAR(50) NULL,
	id_cuenta_interna INT NULL,

	CONSTRAINT PK_CHEQUE_CHEQUE PRIMARY KEY (id_cheque),
	CONSTRAINT FK_CHEQUE_CUENTA_DESTINO FOREIGN KEY (id_cuenta_destino) REFERENCES CUENTA(id_cuenta),
	CONSTRAINT FK_CHEQUE_BANCO FOREIGN KEY (id_banco) REFERENCES catalogo_generico(id_catalogo_generico),
	CONSTRAINT CH_CHEQUE_NUM_CHEQUE CHECK(LEN(num_cheque) > 0),
	CONSTRAINT UK_CHEQUE_NUM_CHEQUE_BANCO UNIQUE (num_cheque,id_banco),
	CONSTRAINT CH_CHEQUE_CUENTA_EXTERNA CHECK(LEN(num_cheque) > 0),
	CONSTRAINT FK_CHEQUE_CUENTA_INTERNA FOREIGN KEY (id_cuenta_interna) REFERENCES CUENTA(id_cuenta)
)
PRINT 'TABLA cheque CREADA'
GO

CREATE TABLE transferencia(
	id_transferencia INT IDENTITY (1,1),
	cuenta_origen INT NOT NULL,
	cuenta_destino INT NOT NULL,

	CONSTRAINT PK_TRANSFERENCIA PRIMARY KEY (id_transferencia),
	CONSTRAINT FK_TRANSFERENCIA_CUENTA_ORIGEN FOREIGN KEY (cuenta_origen) REFERENCES CUENTA(id_cuenta),
	CONSTRAINT FK_TRANSFERENCIA_CUENTA_DESTINO FOREIGN KEY (cuenta_destino) REFERENCES CUENTA(id_cuenta),
	CONSTRAINT CH_TRANSFERENCIA_CUENTAS CHECK(cuenta_origen != cuenta_destino)
)
PRINT 'TABLA transferencia CREADA'
GO

CREATE TABLE pago_servicio(
	id_pago_servicio INT NOT NULL,
	id_cuenta INT NOT NULL,
	--servicio NVARCHAR(10) NOT NULL,
	id_servicio INT NOT NULL,
	referencia VARCHAR(15) NOT NULL

	CONSTRAINT PK_PAGO_SERVICIO_PAGO_SERVICIO PRIMARY KEY (id_pago_servicio),
	CONSTRAINT FK_PAGO_SERVICIO_CUENTA FOREIGN KEY (id_cuenta) REFERENCES CUENTA(id_cuenta),
	--CONSTRAINT CH_PAGO_SERVICIO_SERVICIO CHECK(servicio = 'Agua' or servicio = 'Luz' or servicio = 'Teléfono')
	CONSTRAINT FK_PAGO_SERVICIO_SERVICIO FOREIGN KEY (id_servicio) REFERENCES catalogo_generico(id_catalogo_generico)
)
PRINT 'TABLA pago_servicio CREADA'
GO

CREATE TABLE transaccion (
	id_transaccion INT IDENTITY(1,1),
	monto DECIMAL(12,2) NOT NULL,
	fecha_realizacion DATETIME NOT NULL DEFAULT GETDATE(),
	--operacion VARCHAR(20) NOT NULL,
	id_operacion INT NOT NULL,
	--tipo_transaccion VARCHAR(20),
	id_tipo_transaccion INT NOT NULL,
	id_tarjeta INT NULL,
	id_pago INT NULL ,
	id_transferencia INT NULL,
	id_pago_servicio INT NULL,
	id_cheque INT NULL,

	CONSTRAINT PK_TRANSACCION PRIMARY KEY (id_transaccion),
	CONSTRAINT CH_TRANSACCION_MONTO CHECK(monto > 0),
	CONSTRAINT FK_TRANSACCION_TARJETA FOREIGN KEY (id_tarjeta) REFERENCES TARJETA(id_tarjeta),
	CONSTRAINT FK_TRANSACCION_PAGO FOREIGN KEY (id_pago) REFERENCES pago(id_pago),
	CONSTRAINT FK_TRANSACCION_TRANSFERENCIA FOREIGN KEY (id_transferencia) REFERENCES TRANSFERENCIA(id_transferencia),
	CONSTRAINT FK_TRANSACCION_PAGO_SERVICIO FOREIGN KEY (id_pago_servicio) REFERENCES PAGO_SERVICIO(id_pago_servicio),
	CONSTRAINT FK_TRANSACCION_CHEQUE FOREIGN KEY (id_cheque) REFERENCES CHEQUE(id_cheque),
	CONSTRAINT FK_TRANSACCION_OPERACION FOREIGN KEY (id_operacion) REFERENCES catalogo_generico(id_catalogo_generico),
	CONSTRAINT FK_TRANSACCION_TIPO_TRANSACCION FOREIGN KEY (id_tipo_transaccion) REFERENCES catalogo_generico(id_catalogo_generico),
	CONSTRAINT UK_TRANSACCION_PAGO UNIQUE (id_pago),
	CONSTRAINT UK_TRANSACCION_PAGO_SERVICIO UNIQUE (id_transferencia),
	CONSTRAINT UK_TRANSACCION_CHEQUE UNIQUE (id_cheque)
)
PRINT 'TABLA transaccion CREADA'
GO

CREATE TABLE cliente_cuenta(
	id_cliente_cuenta INT IDENTITY(1,1),
	id_cliente INT NOT NULL,
	id_cuenta INT NOT NULL,

	CONSTRAINT PK_CLIENTE_CUENTA_CLIENTE_CUENTA PRIMARY KEY (id_cliente_cuenta),
	CONSTRAINT FK_CLIENTE_CUENTA_CLIENTE FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
	CONSTRAINT FK_CLIENTE_CUENTA_CUENTA FOREIGN KEY (id_cuenta) REFERENCES CUENTA(id_cuenta),
	CONSTRAINT UK_CLIENTE_CUENTA_CLIENTE_CUENTA UNIQUE(id_cliente,id_cuenta)
)
PRINT 'TABLA cliente_cuenta CREADA'
GO