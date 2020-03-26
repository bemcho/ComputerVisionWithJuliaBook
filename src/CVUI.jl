module CVUI
export initUI
const image_filters = ("*.png", "*.jpg", "*.gif", "*.tiff")

include("CVProcessing.jl")

using Gtk, ImageView, .CVProcessing

function open_file(w)
    path = open_dialog("Open image file", GtkNullContainer(), image_filters)
    processedImage = CVProcessing.open_file(path)
    imshow!(canvas, processedImage)
end

function save_file(w)
    path = save_dialog("Save image file", GtkNullContainer(), image_filters)
    CVProcessing.save_file(path, processedImage)
end

function resize_image(w)
    println("Resize image called")
end

function crop_image(w)
    println("Crop image called")
end

function scale_image(w)
    println("Scale image called")
end

function initUI()
    builder = GtkBuilder(
        filename = joinpath(
            @__DIR__,
            "../resource/gtk",
            "ComputerVisionWithJuliaBook.glade",
        ),
    )

    winDraw = builder["main_window_draw"]
    winToolbar = builder["main_window_toolbar"]

    mainGrid = builder["main_draw_canvas_container"]
    global drawAreaFrame, canvas = ImageView.frame_canvas(:auto)
    push!(mainGrid, drawAreaFrame)
    global processedImage = CVProcessing.defaultimage()

    imshow!(canvas, processedImage)

    # open/save
    connect_button(open_file, builder["open_image_btn"], "clicked", true)
    connect_button(save_file, builder["save_image_btn"], "clicked", true)

    # Dimensions
    connect_button(resize_image, builder["image_dimensions_resize_btn"], "clicked", true)
    connect_button(crop_image, builder["image_dimensions_crop_btn"], "clicked", true)
    connect_button(scale_image, builder["image_dimensions_scale_btn"], "clicked", true)


    showall.([winDraw, winToolbar])

    if !isinteractive()
        c = Condition()
        signal_connect(winDraw, :destroy) do widget
            notify(c)
        end
        wait(c)
    end
end

connect_button(handler, btn, event, after = true) =
    signal_connect(handler, btn, event, after)
end
