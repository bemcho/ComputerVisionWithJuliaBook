module CVProcessing

export open_file, save_file, testimage, defaultimage

using Images, ImageView, TestImages, FileIO

open_file(path) = FileIO.load(path)

save_file(path, processedImage) = FileIO.save(path, processedImage)

testimage(name) = TestImages.testimage(name)

defaultimage() = FileIO.load(joinpath(@__DIR__, "../resource/img", "lighthouse.png"))

end
