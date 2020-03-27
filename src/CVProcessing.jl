module CVProcessing

export open_file, save_file, testimage, defaultimage, resize_image, scale_image

using Images, ImageView, TestImages, ImageTransformations, FileIO

open_file(path) = FileIO.load(path)

save_file(path, processedImage) = FileIO.save(path, processedImage)

testimage(name) = TestImages.testimage(name)

defaultimage() = FileIO.load(joinpath(@__DIR__, "../resource/img", "lighthouse.png"))

resize_image(img, w, h) = imresize(img, (convert(Int, h), convert(Int, w)))

function scale_image(img, w, h, scale)
    height, width = size(img)
    scale_percentage_w = w / width + scale
    scale_percentage_h = h / height + scale
    new_size = trunc.(Int, (width * scale_percentage_w, height * scale_percentage_h))
    resized_image = imresize(img, new_size)
end
end
