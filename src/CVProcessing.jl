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
    scale_percentage_w = round(w / width + scale, digits = 2)
    scale_percentage_h = round(h / height + scale, digits = 2)
    @async println(
        "w: ",
        w,
        " h: ",
        h,
        " scale: ",
        scale,
        " spw: ",
        scale_percentage_w,
        " sph: ",
        scale_percentage_h,
    )
    new_size = trunc.(Int, (height * scale_percentage_h, width * scale_percentage_w))
    @async println(reverse(new_size))
    resized_image = imresize(img, new_size)
end
end
