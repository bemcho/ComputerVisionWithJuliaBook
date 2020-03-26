module CVProcessing

export open_file, save_file, testimage, defaultimage, resize_image

using Images, ImageView, TestImages, ImageTransformations, FileIO

open_file(path) = FileIO.load(path)

save_file(path, processedImage) = FileIO.save(path, processedImage)

testimage(name) = TestImages.testimage(name)

defaultimage() = FileIO.load(joinpath(@__DIR__, "../resource/img", "lighthouse.png"))

function resize_image(img, w, h)
    println("CVProcessing.Resize image called")
    return imresize(img, (convert(Int, h), convert(Int, w)))
end
end
