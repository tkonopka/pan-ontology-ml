# modifications.R
# create modified version of ontologies

# file locations
obo.dir = file.path("..", "data", "obo")


# create an fbdv derivative with more is-a relationships
fbdv.file = file.path(obo.dir, "fbdv.obo")
fbdv.isa.file = file.path(obo.dir, "fbdv-isa.obo")
fbdv = readLines(fbdv.file)
fbdv.isa = gsub("relationship: substage_of", "is_a:", fbdv)
write(fbdv.isa, fbdv.isa.file)


# create a go derivative with more is-a relationships
go.file = file.path(obo.dir, "go.obo")
go.isa.file = file.path(obo.dir, "go-isa.obo")
go = readLines(go.file)
go.isa = gsub("relationship: part_of", "is_a:", go)
write(go.isa, go.isa.file)

