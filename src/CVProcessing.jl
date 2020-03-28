module CVProcessing

export open_file, save_file, testimage, defaultimage, resize_image, scale_image, crop_image

using Images, ImageView, TestImages, ImageTransformations, FileIO

open_file(path) = FileIO.load(path)

save_file(path, processedImage) = FileIO.save(path, processedImage)

testimage(name) = TestImages.testimage(name)

defaultimage() = FileIO.load(joinpath(@__DIR__, "../resource/img", "lighthouse.png"))

resize_image(img, w, h) = imresize(img, (convert(Int, h), convert(Int, w)))

function scale_image(img, w, h, scale)
    height, width = size(img)

    scale_percentage_h = round(convert(Int, h) / height + scale, digits = 2)
    scale_percentage_w = round(convert(Int, w) / width + scale, digits = 2)

    new_size = trunc.(Int, (height * scale_percentage_h, width * scale_percentage_w))
    imresize(img, new_size)
end

function crop_image(img, topLeftX, topLeftY, bottomRightX, bottomRightY)
    img[
        convert(Int, topLeftY):convert(Int, bottomRightY),
        convert(Int, topLeftX):convert(Int, bottomRightX),
    ]
end

end
