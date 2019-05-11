create database control_trafico
print 'control_trafico database creation done'
go

use control_trafico
go

create table catalogo_generico
(
    id_catalogo_generico int not null, -- primary key column
    categoria nvarchar(50) not null,
    valor nvarchar(50) not null,
    activo bit not null,
    parental int null,

    constraint pk_catalogo_generico primary key (id_catalogo_generico),
	constraint ch_catalogo_generico_categoria check(len(categoria) > 0),
	constraint ch_catalogo_generico_valor check(len(valor) > 0),
	constraint uk_catalogo_generico_categoria_valor unique (categoria,valor),
    constraint fk_catalogo_generico_parental foreign key (id_catalogo_generico) references catalogo_generico(id_catalogo_generico)
)
print 'catalogo_generico table creation done'
go

create function CATEGORIACATALOGO
(
	@id_catalogo int
)
returns nvarchar(50)
begin
	declare @cat nvarchar(50);
	set @cat = (select categoria from catalogo_generico where id_catalogo_generico = @id_catalogo);
	return @cat;
end
go
print 'CATEGORIACATALOGO function creation done'
go

create table vehiculo
(
    id_vehiculo int not null, -- primary key column
    placa varchar(7) not null,
    anno smallint not null,
	modelo int not null,
	cantidad_pasajeros int not null,

	constraint pk_vehiculo primary key (id_vehiculo),
	constraint uk_vehiculo_placa unique (placa),
    constraint ch_vehiculo_placa check(((left(placa,1) = 'P')or(left(placa,1) = 'M')or(left(placa,1) = 'A')) and (right(placa,6) LIKE '[0-9][0-9][0-9][A-Z][A-Z][A-Z]') and (len(placa)=7)),
	constraint fk_vehiculo_modelo foreign key (modelo) references catalogo_generico(id_catalogo_generico),
	constraint ch_vehiculo_modelo check(dbo.CATEGORIACATALOGO(modelo)='modelo_vehiculo')
)
print 'vehiculo table creation done'
go

create table licencia
(
    id_licencia int not null, -- primary key column
    nombre1 varchar(30) not null,
    nombre2 varchar(30) null,
    apellido1 varchar(30) not null,
    apellido2 varchar(30) null,
    fecha_nacimiento date not null,
    fecha_primera_licencia date not null,
    fecha_vencimiento date not null,
	tipo int not null,

    constraint pk_licencia primary key (id_licencia),
	constraint fk_licencia foreign key (tipo) references catalogo_generico(id_catalogo_generico),
	constraint ch_licencia_tipo check(dbo.CATEGORIACATALOGO(tipo)='tipo_licencia'),
    constraint ch_licencia_nombre_apellido check(nombre1 NOT LIKE '%[^A-Z]%' and nombre2 NOT LIKE '%[^A-Z]%' and apellido1 NOT LIKE '%[^A-Z]%' and apellido2 NOT LIKE '%[^A-Z]%'),
    constraint ch_licencia_fecha_nacimiento check(datediff(year,fecha_nacimiento,getdate())>=16),
    constraint ch_licencia_fecha_primera_licencia check(datediff(day,fecha_primera_licencia,getdate())>=0),
    constraint ch_licencia_fecha_vencimiento check(datediff(day,getdate(),fecha_vencimiento)>=0)
)
print 'licencia table creation done'
go

create function PERMISOCONDUCIR
(
	@id_vehiculo int,
	@id_licencia int
)
returns bit
begin
	declare @permiso bit;
	declare @tipo_licencia nvarchar(50);
	set @tipo_licencia
	=(
		select
			c.valor
		from
			catalogo_generico as c
		where c.id_catalogo_generico in
			(
				select
				l.tipo
				from
				licencia as l
				where l.id_licencia = @id_licencia
			)
	);
	declare @tipo_vehiculo nvarchar(50);
	set @tipo_vehiculo
	=(
		select
			c2.valor
		from
			catalogo_generico as c1
		left join catalogo_generico as c2 on c1.parental = c2.id_catalogo_generico
		where c1.id_catalogo_generico in
			(
				select
					v.modelo
				from
					vehiculo as v
				where v.id_vehiculo = @id_vehiculo
			)
	);

	if @tipo_vehiculo = 'MOTOCICLETA'
	begin
		if @tipo_licencia = 'M'
			set @permiso = 1;
		else
			set @permiso = 0;
	end
	else
	begin
		if @tipo_licencia = 'M'
			set @permiso = 0;
		else
			set @permiso = 1;
	end
	return @permiso;
end
go
print 'PERMISOCONDUCIR function creation done'
go

create table vehiculo_licencia
(
    id_vehiculo_licencia int not null, -- primary key column
    id_vehiculo int not null,
    id_licencia int not null,

    constraint pk_vehiculo_licencia primary key (id_vehiculo_licencia),
    constraint fk_vehiculo_licencia_vehiculo foreign key (id_vehiculo) references vehiculo(id_vehiculo),
    constraint fk_vehiculo_licencia_licencia foreign key (id_licencia) references licencia(id_licencia),
    constraint uk_vehiculo_licencia_vehiculo_licencia unique (id_vehiculo, id_licencia),
	constraint ck_vehiculo_licencia_vehiculo check(dbo.PERMISOCONDUCIR(id_vehiculo,id_licencia) = 1)
)
print 'vehiculo_licencia table creation done'
go

create table dispositivo
(
    id_dispositivo int not null, -- primary key column
    direccion varchar(60) not null,
    latitud decimal(18,14) not null,
    longitud decimal(18,14) not null,
    limite_velocidad decimal(8,5) not null,

    constraint pk_dispositivo primary key (id_dispositivo),
    constraint ch_dispositivo_limite_velocidad check(limite_velocidad>0)
)
print 'dispositivo table creation done'
go

create table distancia_dispositivos
(
    id_distancia int not null, -- primary key column
    id_dispositivo1 int not null,
    id_dispositivo2 int not null,
    distancia decimal(8,5) not null,

    constraint pk_distancia_dispositivos primary key (id_distancia),
    constraint fk_distancia_dispositivos_dispositivo_1 foreign key (id_dispositivo1) references dispositivo(id_dispositivo),
    constraint fk_distancia_dispositivos_dispositivo_2 foreign key (id_dispositivo2) references dispositivo(id_dispositivo),
    constraint uk_distancia_dispositivos_dispositivos unique(id_dispositivo1,id_dispositivo2),
	constraint ch_distancia_dispositivos_distancia check(distancia>0),
	constraint ch_distancia_dispositivos_dispositivos check(id_dispositivo1 != id_dispositivo2)
)
print 'distancia_dispositivos table creation done'
go

create table control
(
    id_control int not null, -- primary key column
    velocidad decimal(8,5) not null,
    numero_pasajeros int not null,
    fechahora datetime not null,
    id_vehiculo int not null,
    id_licencia int not null,
    id_dispositivo int not null,

    constraint pk_control primary key (id_control),
    constraint fk_control_vehiculo foreign key (id_vehiculo) references vehiculo(id_vehiculo),
    constraint fk_control_licencia foreign key (id_licencia) references licencia(id_licencia),
    constraint fk_control_dispositivo foreign key (id_dispositivo) references dispositivo(id_dispositivo),
    constraint ch_control_velocidad check(velocidad>0),
    constraint ch_control_numero_pasajeros check(numero_pasajeros>0),
    constraint ch_control_fechahora check(datediff(second,fechahora,getdate())>=0)
)
print 'control table creation done'
go

create table multa
(
    id_multa int not null identity(1,1), -- primary key column
    id_control int not null,
    motivo nvarchar(50) not null,
    monto decimal(5,2) not null,

    constraint pk_multa primary key (id_multa),
    constraint fk_multa_control foreign key (id_control) references control(id_control),
	constraint ch_multa_motivo check(len(motivo)>0),
	constraint ch_multa_monto check(monto>0)
)
print 'multa table creation done'
go

CREATE FUNCTION dbo.HABILITADOCONDUCIR
(
	@id_licencia int,
	@id_vehiculo int
)
RETURNS bit
BEGIN
	declare @cuenta int;
	set @cuenta =
		(
			select COUNT(1)
			from vehiculo_licencia as vl
			where (vl.id_licencia = @id_licencia) and (vl.id_vehiculo = @id_vehiculo)
		);
	declare @res bit
	if @cuenta = 0
		set @res = 0;
	else
		set @res = 1;
	return @res;
END
GO
print 'HABILITADOCONDUCIR function creation done'
go

CREATE FUNCTION dbo.DISTANCIAPUNTOS
(
	@id_punto1 int,
	@id_punto2 int
)
RETURNS decimal(8,5)
BEGIN
	declare @dist decimal(8,5);

	if @id_punto1 = @id_punto2
		set @dist = 0;
	else
		begin
			if @id_punto1 > @id_punto2
				begin
					if (select count(1) from distancia_dispositivos as dd where (dd.id_dispositivo1 = @id_punto2) and (dd.id_dispositivo2 = @id_punto1)) > 0
						set @dist = (select dd.distancia from distancia_dispositivos as dd where (dd.id_dispositivo1 = @id_punto2) and (dd.id_dispositivo2 = @id_punto1));
					else
						set @dist = -1;
				end
			else
				begin
					if (select count(1) from distancia_dispositivos as dd where (dd.id_dispositivo1 = @id_punto1) and (dd.id_dispositivo2 = @id_punto2)) > 0
						set @dist = (select dd.distancia from distancia_dispositivos as dd where (dd.id_dispositivo1 = @id_punto1) and (dd.id_dispositivo2 = @id_punto2));
					else
						set @dist = -1;
				end
		end
	return @dist
END
GO
print 'DISTANCIAPUNTOS function creation done'
go

CREATE FUNCTION dbo.MULTAENTREPUNTOS
(
	@id_vehiculo int,
	@fechahora datetime
)
RETURNS bit
AS
BEGIN
	-- Declare the return variable here
	declare @multa bit;

	-- Add the T-SQL statements to compute the return value here
	declare @lasttow table
	(
		fila bigint,
		id_control int,
		velocidad decimal(8,5),
		numero_pasajeros  int,
		fechahora datetime,
		id_vehiculo int,
		id_licencia int,
		id_dispositivo int
	);

	insert into @lasttow
	select top(2)
	ROW_NUMBER() over(order by c.fechahora desc)  as fila,
	c.*
	from
	control as c
	where
	c.id_vehiculo = @id_vehiculo
	and c.fechahora <= @fechahora
	order by c.fechahora desc;

	if (select count(1) from @lasttow) < 2
		set @multa = 0;
	else
		begin
		declare @punto1 int;
		set @punto1 = (select l.id_dispositivo from @lasttow as l where l.fila = 2);
		declare @punto2 int;
		set @punto2 = (select l.id_dispositivo from @lasttow as l where l.fila = 1);

		declare @tiempo1 datetime;
		set @tiempo1 = (select l.fechahora from @lasttow as l where l.fila = 2);
		declare @tiempo2 datetime;
		set @tiempo2 = (select l.fechahora from @lasttow as l where l.fila = 1);

		declare @distancia decimal(8,5);
		set @distancia = dbo.DISTANCIAPUNTOS(@punto1,@punto2);

		declare @tiempo int;
		set @tiempo = datediff(second,@tiempo1,@tiempo2);
	
		if (@distancia <= 0) or (@tiempo <= 0)
			set @multa = 0;
		else
			begin
				declare @velocidad float;
				declare @tie float;
				set @tie = CAST(@tiempo as float)/CAST(3600  as float);
				set @velocidad = @distancia/@tie;

				declare @vel_max float;
				set @vel_max = convert(float,(select d.limite_velocidad from dispositivo as d where d.id_dispositivo = (select l.id_dispositivo from @lasttow as l where l.fila = 1)));

				if @velocidad > @vel_max
					set @multa = 1;
				else
					set @multa = 0;
			end
		end
	-- Return the result of the function
	return @multa;
END
GO
print 'MULTAENTREPUNTOS function creation done'
go

CREATE TRIGGER [dbo].[_control_ai]
   ON  [dbo].[control]
   AFTER insert
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for trigger here
	declare @nuevasmultas table
	(
		id_control int,
		motivo nvarchar(50),
		monto decimal(5,2)
	);
	declare @motivo as nvarchar(50);
	declare @monto as decimal(5,2);

	set @motivo = 'Exceso de Velocidad';
	set @monto = 300;
	insert into @nuevasmultas
	select
		i.id_control,
		@motivo,
		@monto
	from inserted as i
	join dispositivo as d on i.id_dispositivo = d.id_dispositivo
	where i.velocidad > d.limite_velocidad;

	set @motivo = 'Exceso de Pasajeros';
	set @monto = 200;
	insert into @nuevasmultas
	select
		i.id_control,
		@motivo,
		@monto
	from inserted as i
	join vehiculo as v on v.id_vehiculo = i.id_vehiculo
	where i.numero_pasajeros > v.cantidad_pasajeros;

	set @motivo = 'Licencia No habilitada';
	set @monto = 100;
	insert into @nuevasmultas
	select
		i.id_control,
		@motivo,
		@monto
	from 
	inserted as i,
	vehiculo_licencia as vl
	where dbo.HABILITADOCONDUCIR(vl.id_licencia,vl.id_vehiculo) = 0;

	set @motivo = 'Exceso de Velocidad entre puntos';
	set @monto = 300;
	insert into @nuevasmultas
	select
		i.id_control,
		@motivo,
		@monto
	from inserted as i
	where dbo.MULTAENTREPUNTOS(i.id_vehiculo,i.fechahora) = 1;


	insert into multa(id_control,motivo,monto)
	select * from @nuevasmultas
END
GO
print '_control_ai trigger creation done'
go