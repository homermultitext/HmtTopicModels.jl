
@testset "Test postprocessing raw corpus" begin
    cn = CitableNode(CtsUrn("urn:cts:dummy:tests.test1:1"), "This is a short passage of text")
    c = CitableTextCorpus([cn])
    tidied = tmclean(c, ["This"])
    expected = "short passage text"
    @test tidied.corpus[1].text == expected
end