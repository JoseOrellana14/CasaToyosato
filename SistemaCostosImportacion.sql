Use SistemasCostosImportacion

-- Crear tabla Proveedor
CREATE TABLE Proveedor (
    CodigoProveedor VARCHAR(50) PRIMARY KEY,
    NombreProveedor VARCHAR(255),
    DireccionProveedor VARCHAR(255),
    Ciudad VARCHAR(100),
    Pais VARCHAR(100)
);

-- Crear tabla Producto
CREATE TABLE Producto (
    CodigoProducto VARCHAR(50) PRIMARY KEY,
    DescripcionProducto VARCHAR(255),
    PrecioUnitario FLOAT,
    CodigoProveedor VARCHAR(50),
    FOREIGN KEY (CodigoProveedor) REFERENCES Proveedor(CodigoProveedor)
);

-- Crear tabla Pedido
CREATE TABLE Pedido (
    CodigoPedido VARCHAR(50) PRIMARY KEY,
    DescripcionPedido VARCHAR(255),
    Cantidad INT,
    CostoTotal FLOAT,
    CodigoProducto VARCHAR(50),
    CodigoProveedor VARCHAR(50),
    FOREIGN KEY (CodigoProducto) REFERENCES Producto(CodigoProducto),
    FOREIGN KEY (CodigoProveedor) REFERENCES Proveedor(CodigoProveedor)
);

-- Crear tabla EmpresaTransportadora
CREATE TABLE EmpresaTransportadora (
    CodigoEmpresaTransportadora VARCHAR(50) PRIMARY KEY,
    NombreEmpresaTransportadora VARCHAR(255),
    Ruta VARCHAR(255),
    Distancia FLOAT,
    PesoVolumen FLOAT,
    CostoTotalEmpresaTransportadora FLOAT,
	CodigoPedido VARCHAR(50),
    FOREIGN KEY (CodigoPedido) REFERENCES Pedido(CodigoPedido)
);

-- Crear tabla EmpresaSeguros
CREATE TABLE EmpresaSeguros (
    CodigoSeguro VARCHAR(50) PRIMARY KEY,
    NombreEmpresaSeguros VARCHAR(255),
    Ruta VARCHAR(255),
    Distancia FLOAT,
    PesoVolumen FLOAT,
    CostoTotalEmpresaSeguros FLOAT,
	CodigoPedido VARCHAR(50),
    FOREIGN KEY (CodigoPedido) REFERENCES Pedido(CodigoPedido)
);

-- Crear tabla CostosFronterizos con campo calculado
CREATE TABLE CostosFronterizos (
    CodigoCostosFronterizos VARCHAR(50) PRIMARY KEY,
    DocumentacionTramites FLOAT,
    InspeccionesControles FLOAT,
    PeajesInternacionales FLOAT,
    CostosAlmacenamientoTemporal FLOAT,
    TotalCostosFronterizos AS (DocumentacionTramites + InspeccionesControles + PeajesInternacionales + CostosAlmacenamientoTemporal) PERSISTED,
	CodigoPedido VARCHAR(50),
    FOREIGN KEY (CodigoPedido) REFERENCES Pedido(CodigoPedido)
);

-- Crear tabla ValorFOB
CREATE TABLE ValorFOB (
    CodigoValorFOB VARCHAR(50) PRIMARY KEY,
    CostoProductoBase FLOAT,
    CostoEmpresaTransportadoraOrigen FLOAT,
    SeguroOrigen FLOAT,
    TotalValorFOB AS (CostoProductoBase + CostoEmpresaTransportadoraOrigen + SeguroOrigen) PERSISTED,
	CodigoPedido VARCHAR(50),
    FOREIGN KEY (CodigoPedido) REFERENCES Pedido(CodigoPedido)
);

-- Crear tabla FleteInternacional con campo calculado
CREATE TABLE FleteInternacional (
    CodigoFleteInternacional VARCHAR(50) PRIMARY KEY,
    ValorFOB FLOAT,
    CostosFronterizos FLOAT,
    TotalFleteInternacional AS (ValorFOB + CostosFronterizos) PERSISTED,
    CodigoPedido VARCHAR(50),
    FOREIGN KEY (CodigoPedido) REFERENCES Pedido(CodigoPedido),
	FOREIGN KEY (CostosFronterizos) REFERENCES CostosFronterizos(TotalCostosFronterizos),
	FOREIGN KEY (ValorFOB) REFERENCES ValorFOB(TotalValorFOB)
);

-- Crear tabla ValorCIF con campo calculado
CREATE TABLE ValorCIF (
    CodigoValorCIF VARCHAR(50) PRIMARY KEY,
    TotalValorFOB FLOAT,
    FleteInternacional FLOAT,
    Seguro FLOAT,
    TotalValorCIF AS (TotalValorFOB + FleteInternacional + Seguro) PERSISTED,
    CodigoPedido VARCHAR(50),
    FOREIGN KEY (CodigoPedido) REFERENCES Pedido(CodigoPedido),
	FOREIGN KEY (TotalValorFOB) REFERENCES ValorFOB(TotalValorFOB),
    FOREIGN KEY (FleteInternacional) REFERENCES FleteInternacional(TotalFleteInternacional),
    FOREIGN KEY (Seguro) REFERENCES EmpresaSeguros(CostoTotal)
);

-- Crear tabla TasaImpositiva
CREATE TABLE TasaImpositiva (
    CodigoTasaImpositiva VARCHAR(50) PRIMARY KEY,
    TasaArancelaria FLOAT,
    TasaIVA FLOAT,
    TasaIT FLOAT
);

-- Crear tabla GravamenArancelarios con campo calculado
CREATE TABLE GravamenArancelarios (
    CodigoGravamenArancelario VARCHAR(50) PRIMARY KEY,
    ValorCIF FLOAT,
    TasaArancelaria FLOAT,
    GrvamenArancelario AS (ValorCIF * TasaArancelaria) PERSISTED,
	CodigoPedido VARCHAR(50),
	FOREIGN KEY (CodigoPedido) REFERENCES Pedido(CodigoPedido),
    FOREIGN KEY (ValorCIF) REFERENCES ValorCIF(TotalValorCIF),
	FOREIGN KEY (TasaArancelaria) REFERENCES TasaImpositiva(TasaArancelaria)
);

-- Crear tabla IVA con campos calculados
CREATE TABLE IVAs (
    CodigoIVA VARCHAR(50) PRIMARY KEY,
    ValorCIF FLOAT,
    GrvamenArancelario FLOAT,
    BaseIVA AS (ValorCIF + GrvamenArancelario) PERSISTED,
    TasaIVA FLOAT,
    IVA AS (BaseIVA * TasaIVA) PERSISTED,
	CodigoPedido VARCHAR(50),
	FOREIGN KEY (CodigoPedido) REFERENCES Pedido(CodigoPedido),
    FOREIGN KEY (ValorCIF) REFERENCES ValorCIF(TotalValorCIF),
    FOREIGN KEY (GrvamenArancelario) REFERENCES GravamenArancelarios(GrvamenArancelario),
	FOREIGN KEY (TasaIVA) REFERENCES TasaImpositiva(TasaIVA)
);

-- Crear tabla IT con campo calculado
CREATE TABLE ITs (
    CodigoIT VARCHAR(50) PRIMARY KEY,
    ValorCIF FLOAT,
    TasaIT FLOAT,
    IT AS (ValorCIF * TasaIT) PERSISTED,
	CodigoPedido VARCHAR(50),
	FOREIGN KEY (CodigoPedido) REFERENCES Pedido(CodigoPedido),
    FOREIGN KEY (ValorCIF) REFERENCES ValorCIF(TotalValorCIF),
	FOREIGN KEY (TasaIT) REFERENCES TasaImpositiva(TasaIT)
);

-- Crear tabla InformeCostoTotalImportacionPedido
-- CREATE TABLE InformeCostoTotalImportacionPedido (
--    CodigoCostoFinalImportacionPedido VARCHAR(50) PRIMARY KEY,
--    Valor FLOAT,
--    CodigoPedido VARCHAR(50),
--    FOREIGN KEY (CodigoPedido) REFERENCES Pedido(CodigoPedido)
--);

-- Crear tabla Pedido
CREATE TABLE InformeCostoTotalImportacionPedido (
	CodigoCostoFinalImportacionPedido VARCHAR(50) PRIMARY KEY,
	FechaInforme DATE,
    CodigoPedido VARCHAR(50),
    DescripcionPedido VARCHAR(255),
    Cantidad INT, --Pedido
    CostoTotal FLOAT, --Pedido
    --CodigoProducto VARCHAR(50),
    NombreProveedor VARCHAR(255),
    NombreEmpresaTransportadora VARCHAR(255),
    NombreEmpresaSeguros VARCHAR(255),
	TotalCostosFronterizos,
	TotalValorCIF,
    GrvamenArancelario,
    IVA,
	IT,

	FOREIGN KEY (CodigoPedido) REFERENCES Pedido(CodigoPedido),
	FOREIGN KEY (DescripcionPedido) REFERENCES Pedido(DescripcionPedido),
	FOREIGN KEY (Cantidad) REFERENCES Pedido(Cantidad),
	FOREIGN KEY (CostoTotal) REFERENCES Pedido(CostoTotal),
    FOREIGN KEY (NombreProveedor) REFERENCES Proveedor(NombreProveedor),
    FOREIGN KEY (NombreEmpresaTransportadora) REFERENCES EmpresaTransportadora(NombreEmpresaTransportadora),
    FOREIGN KEY (NombreEmpresaSeguros) REFERENCES EmpresaSeguros(NombreEmpresaSeguros),
    FOREIGN KEY (TotalCostosFronterizos) REFERENCES CostosFronterizos(TotalCostosFronterizos),
    FOREIGN KEY (TotalValorCIF) REFERENCES ValorCIF(TotalValorCIF),
    FOREIGN KEY (GrvamenArancelario) REFERENCES GravamenArancelarios(GrvamenArancelario),
    FOREIGN KEY (IVA) REFERENCES IVAs(IVA),
    FOREIGN KEY (IT) REFERENCES ITs(IT)
);

-- Crear tabla Cliente
CREATE TABLE Cliente (
    CodigoCliente VARCHAR(50) PRIMARY KEY,
    Nombre VARCHAR(255),
    TipoCliente VARCHAR(50)
);

-- Crear tabla DescuentoCliente
CREATE TABLE DescuentoCliente (
    IDDescuentoCliente VARCHAR(50) PRIMARY KEY,
    TipoCliente VARCHAR(50),
    Porcentaje FLOAT,
    FOREIGN KEY (TipoCliente) REFERENCES Cliente(TipoCliente)
);

-- Crear tabla PorcentajeMargenGanancia
CREATE TABLE PorcentajeMargenGanancia (
    CodigoPorcentajeMargenGanancia VARCHAR(50) PRIMARY KEY,
    Descripcion VARCHAR(255),
    Porcentaje FLOAT,
    FOREIGN KEY (Descripcion) REFERENCES Producto(Descripcion)
);



-- Crear tabla InformeCostoTotalImportacionProducto
CREATE TABLE InformeCostoTotalImportacionProducto (
    CodigoCostoFinalImportacionProducto VARCHAR(50) PRIMARY KEY,
    Valor FLOAT,
    CodigoProducto VARCHAR(50),
    FOREIGN KEY (CodigoProducto) REFERENCES Producto(CodigoProducto)
);

-- Crear tabla PrecioFinalGananciaImportacion
CREATE TABLE PrecioFinalGananciaImportacion (
    CodigoPrecioFinalImportacion VARCHAR(50) PRIMARY KEY,
    GananciaInicial FLOAT,
    GananciaFinal FLOAT,
    PrecioFinal FLOAT,
    CodigoProducto VARCHAR(50),
    FOREIGN KEY (CodigoProducto) REFERENCES Producto(CodigoProducto)
);

-- Crear tabla InformeFinalGananciaImportacion
CREATE TABLE InformeFinalGananciaImportacion (
    CodigoInformeFinalGanancia VARCHAR(50) PRIMARY KEY,
    GananciaFinal FLOAT
);
