// Versao minima: so baixa e promove o cabecalho. Nada mais.
let
    Fonte = Csv.Document(
        Web.Contents("https://sdmx.oecd.org/public/rest/data/OECD.ECO.MPD,DSD_AN_HOUSE_PRICES@DF_HOUSE_PRICES,1.0/?startPeriod=2015&format=csvfilewithlabels"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    Cabecalho = Table.PromoteHeaders(Fonte, [PromoteAllScalars = true])
in
    Cabecalho
