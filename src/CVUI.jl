module CVUI
include("CVProcessing.jl")
using Gtk, GtkReactive, ImageView, .CVProcessing

export initUI

const image_filters = ("*.png", "*.jpg", "*.gif", "*.tiff")
# image drawing

function initUI()
    builder = GtkBuilder(
        filename = joinpath(
            @__DIR__,
            "../resource/gtk",
            "ComputerVisionWithJuliaBook.glade",
        ),
    )

    # windows and dialogs
    global winDraw = builder["main_window_draw"]
    winToolbar = builder["main_window_toolbar"]
    global winEditDimensions = builder["edit_dimensions_window"]

    #  signals handling
    connect_widget(w -> hide(winEditDimensions), winDraw, "activate-focus")
    connect_widget(w -> hide(winEditDimensions), winToolbar, "activate-focus")

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

    redrawImage(CVProcessing.defaultimage())

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
set_size!(w::Gtk.GtkWidget, width::Int, height::Int) = ccall(
    (:gtk_widget_set_size_request, Gtk.libgtk),
    Nothing,
    (Ptr{GObject}, Cint, Cint),
    w,
    width,
    height,
)

function redrawImage(img)
    global processedImage = img
    global currentHeight, currentWidth = size(processedImage)

    drawAreaFrame, canvas = ImageView.frame_canvas(:none)
    set_size!(winDraw, currentWidth, currentHeight)

    empty!(winDraw)
    push!(winDraw, drawAreaFrame)
    imshow!(canvas, img)
    showall(winDraw)
end

function open_file(w)
    path = open_dialog("Open image file", GtkNullContainer(), image_filters)
    redrawImage(CVProcessing.open_file(path))
end

function save_file(w)
    path = save_dialog("Save image file", GtkNullContainer(), image_filters)
    CVProcessing.save_file(path, processedImage)
end

function resize_image(w)
    show(winEditDimensions)
end

function widthset(widget)
    redrawImage(CVProcessing.resize_image(
        processedImage,
        Gtk.GAccessor.value(widget),
        currentHeight,
    ))
end

function heightset(widget)
    redrawImage(CVProcessing.resize_image(
        processedImage,
        currentWidth,
        Gtk.GAccessor.value(widget),
    ))
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
