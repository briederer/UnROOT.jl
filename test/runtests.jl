using ROOTIO
using StaticArrays
using Test

const SAMPLES_DIR = joinpath(@__DIR__, "samples")


ROOTIO.@io struct Foo
    a::Int32
    b::Int64
    c::Float32
    d::SVector{5, UInt8}
end

@testset "io" begin

    d = SA{UInt8}[1, 2, 3, 4, 5]

    foo = Foo(1, 2, 3, d)

    @test foo.a == 1
    @test foo.b == 2
    @test foo.c ≈ 3
    @test d == foo.d

    @test 21 == sizeof(Foo)

    buf = IOBuffer(Vector{UInt8}(1:sizeof(Foo)))
    foo = ROOTIO.unpack(buf, Foo)

    @test foo.a == 16909060
    @test foo.b == 361984551142689548
    @test foo.c ≈ 4.377526f-31
    @test foo.d == UInt8[0x11, 0x12, 0x13, 0x14, 0x15]
end


@testset "Header and Preamble" begin
    fobj = open(joinpath(SAMPLES_DIR, "raw.root"))
    file_preamble = ROOTIO.unpack(fobj, ROOTIO.FilePreamble)
    @test "root" == String(file_preamble.identifier)

    file_header = ROOTIO.unpack(fobj, ROOTIO.FileHeader32)
    @test 100 == file_header.fBEGIN
end


@testset "ROOTFile" begin
    rootfile = ROOTFile(joinpath(SAMPLES_DIR, "raw.root"))
    @test 100 == rootfile.header.fBEGIN
end

@testset "ROOTDictionary" begin
    rootfile = ROOTFile(joinpath(SAMPLES_DIR, "raw.root"))
    rootdir = ROOTIO.ROOTDirectory(rootfile)
    @test 5 == rootdir.fVersion
    @test 1658540644 == rootdir.fDatimeC
    @test 1658540645 == rootdir.fDatimeM
    @test 629 == rootdir.fNbytesKeys
    @test 68 == rootdir.fNbytesName
    @test 100 == rootdir.fSeekDir
    @test 0 == rootdir.fSeekParent
    @test 1619244 == rootdir.fSeekKeys
end
