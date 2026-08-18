// ============================================================
// OECD — Analytical House Price Indicators
// Fonte: API SDMX pública (sem chave, sem scraping)
// Cole no Power BI: Página Inicial > Transformar dados >
//                   Nova Fonte > Consulta em Branco >
//                   Editor Avançado > substitua tudo por isto
// ============================================================
let
    Url =
        "https://sdmx.oecd.org/public/rest/data/"
        & "OECD.ECO.MPD,DSD_AN_HOUSE_PRICES@DF_HOUSE_PRICES,1.0/"
        & "?startPeriod=1970&format=csvfilewithlabels",

    // Csv.Document SEM o parametro Columns fixo — se o OECD acrescentar
    // uma coluna, um numero fixo aqui cortaria dados silenciosamente.
    Bruto = Csv.Document(
        Web.Contents(Url),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),

    Cabecalho = Table.PromoteHeaders(Bruto, [PromoteAllScalars = true]),

    // Fica so o que interessa: o CSV traz 26 colunas, metade e metadado SDMX.
    // MissingField.Ignore evita quebrar se o OECD renomear algo.
    Colunas = Table.SelectColumns(
        Cabecalho,
        {
            "REF_AREA", "Reference area",
            "FREQ", "Frequency of observation",
            "MEASURE", "Measure",
            "UNIT_MEASURE", "Unit of measure",
            "TIME_PERIOD", "OBS_VALUE", "BASE_PER"
        },
        MissingField.Ignore
    ),

    Renomeado = Table.RenameColumns(
        Colunas,
        {
            {"REF_AREA", "CodPais"}, {"Reference area", "Pais"},
            {"FREQ", "CodFreq"}, {"Frequency of observation", "Frequencia"},
            {"MEASURE", "CodMedida"}, {"Measure", "Medida"},
            {"UNIT_MEASURE", "CodUnidade"}, {"Unit of measure", "Unidade"},
            {"TIME_PERIOD", "Periodo"}, {"OBS_VALUE", "Valor"},
            {"BASE_PER", "PeriodoBase"}
        },
        MissingField.Ignore
    ),

    // Ano numerico (Periodo vem "2024" no anual e "2024-Q1" no trimestral)
    ComAno = Table.AddColumn(
        Renomeado, "Ano",
        each try Number.From(Text.Start([Periodo], 4)) otherwise null,
        Int64.Type
    ),

    // Trimestre so existe na frequencia Q
    ComTrimestre = Table.AddColumn(
        ComAno, "Trimestre",
        each if Text.Contains([Periodo], "-Q")
             then try Number.From(Text.End([Periodo], 1)) otherwise null
             else null,
        Int64.Type
    ),

    // Marca agregados: OECD e Euro area NAO sao paises. Manter na base,
    // mas nunca deixar virar barra num ranking de paises.
    Agregados = {"OECD", "Euro area", "Euro area (17 countries)", "European Union"},
    ComTipo = Table.AddColumn(
        ComTrimestre, "TipoArea",
        each if List.Contains(Agregados, [Pais]) then "Agregado" else "Pais",
        type text
    ),

    // ATENCAO: Valor e DECIMAL. Int64.Type aqui arredondaria o indice
    // (114,8 viraria 115) e destruiria a analise.
    Tipado = Table.TransformColumnTypes(
        ComTipo,
        {
            {"Valor", type number},
            {"Pais", type text}, {"Medida", type text},
            {"Unidade", type text}, {"Periodo", type text},
            {"CodMedida", type text}, {"CodFreq", type text}
        }
    ),

    SemNulos = Table.SelectRows(Tipado, each [Valor] <> null)
in
    SemNulos
