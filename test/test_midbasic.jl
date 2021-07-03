@testset "Test basic TEI usage defined by MID module" begin
    tmbldr = HmtTopicModels.HmtTMBuilder("tm builder", "x")
    validnames = EditionBuilders.validElementNames(tmbldr)
    @test length(validnames) == 33
    @test validelname(tmbldr, "p")
    @test validelname(tmbldr, "watermark") == false


    choicexml = "<choice><abbr>Mr.</abbr><expan>Mister</expan></choice>"
    choicenode = EzXML.parsexml(choicexml) |> root
    @test EditionBuilders.validchoice(choicenode)

    wxml = "<w>Word<unclear>less</unclear></w>"
    wnode =  EzXML.parsexml(wxml) |> root
    @test EditionBuilders.collectw(wnode, tmbldr) == "Wordless"

end