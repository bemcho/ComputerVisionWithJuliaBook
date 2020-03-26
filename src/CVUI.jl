module CVUI
export initUI
const image_filters = ("*.png", "*.jpg", "*.gif", "*.tiff")

include("CVProcessing.jl")

using Gtk, ImageView, .CVProcessing

function initUI()
    builder = GtkBuilder(
        filename = joinpath(
            @__DIR__,
            "../resource/gtk",
            "ComputerVisionWithJuliaBook.glade",
        ),
    )

    # windows and dialogs
    winDraw = builder["main_window_draw"]
    winToolbar = builder["main_window_toolbar"]
    global winEditDimensions = builder["edit_dimensions_window"]
    connect_widget(w -> visible(winEditDimensions, false), winDraw, "focus-in-event")
    connect_widget(w -> visible(winEditDimensions, false), winToolbar, "focus-in-event")

    # image drawing
    mainGrid = builder["main_draw_canvas_container"]
    global drawAreaFrame, canvas = ImageView.frame_canvas(:auto)
    push!(mainGrid, drawAreaFrame)
    global processedImage = CVProcessing.defaultimage()
    global currentHeight, currentWidth = size(processedImage)
    global currentScale = 100.0

    # open/save
    connect_widget(open_file, builder["open_image_btn"], "clicked", true)
    connect_widget(save_file, builder["save_image_btn"], "clicked", true)

    # Dimensions
    connect_widget(resize_image, builder["image_dimensions_resize_btn"], "clicked", true)
    connect_widget(crop_image, builder["image_dimensions_crop_btn"], "clicked", true)
    connect_widget(scale_image, builder["image_dimensions_scale_btn"], "clicked", true)

    #dimesnions sliders
    connect_widget(widthset, builder["slider_width_adjustment"], "value-changed")
    connect_widget(heightset, builder["slider_height_adjustment"], "value-changed")
    connect_widget(scaleset, builder["slider_scale_adjustment"], "value-changed")

    imshow!(canvas, processedImage)
    showall.([winDraw, winToolbar])

    if !isinteractive()
        c = Condition()
        signal_connect(winDraw, :destroy) do widget
            notify(c)
        end
        wait(c)
    end
end

connect_widget(handler, w, event, after = true) = signal_connect(handler, w, event, after)

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
    show(winEditDimensions)
end

function widthset(widget)
    currentWidth = Gtk.GAccessor.value(widget)

    processedImage = CVProcessing.resize_image(processedImage, currentWidth, currentHeight)
    imshow!(canvas, processedImage)
end

function heightset(widget)
    currentHeight = Gtk.GAccessor.value(widget)

    processedImage = CVProcessing.resize_image(processedImage, currentWidth, currentHeight)
    imshow!(canvas, processedImage)
end

function crop_image(w)
    println("Crop image called")
    show(winEditDimensions)
end

function scale_image(w)
    println("Scale image called")
    show(winEditDimensions)
end

function scaleset(widget)
    println(Gtk.GAccessor.value(widget))
end
end
