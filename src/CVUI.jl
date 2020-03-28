module CVUI
include("CVProcessing.jl")
using Gtk, ImageView, .CVProcessing

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

    #resize
    global winEditResize = builder["edit_resize_window"]

    #resize
    global winEditCrop = builder["edit_crop_window"]

    #resize
    global winEditScale = builder["edit_scale_window"]

    #sliders
    global widthSlider = builder["slider_width_adjustment"]
    global heightSlider = builder["slider_height_adjustment"]
    global scaleSlider = builder["slider_scale_adjustment"]

    #  signals handling

    # open/save
    connect_widget(open_file, builder["open_image_btn"], "clicked", true)
    connect_widget(save_file, builder["save_image_btn"], "clicked", true)

    # Dimensions
    connect_widget(resize_image, builder["image_dimensions_resize_btn"], "clicked", true)
    connect_widget(crop_image, builder["image_dimensions_crop_btn"], "clicked", true)
    connect_widget(scale_image, builder["image_dimensions_scale_btn"], "clicked", true)

    #resize sliders
    connect_widget(widthset, builder["slider_width_adjustment"], "value-changed")
    connect_widget(heightset, builder["slider_height_adjustment"], "value-changed")

    # resize ok, cancel
    connect_widget(preview_resize, builder["resize_window_preview_btn"], "clicked")
    connect_widget(apply_resize, builder["resize_window_apply_btn"], "clicked")
    connect_widget(cancel_resize, builder["resize_window_cancel_btn"], "clicked")

    # crop ok, cancel
    connect_widget(preview_crop, builder["crop_window_preview_btn"], "clicked")
    connect_widget(apply_crop, builder["crop_window_apply_btn"], "clicked")
    connect_widget(cancel_crop, builder["crop_window_cancel_btn"], "clicked")

    # scale ok, cancel
    connect_widget(preview_scale, builder["scale_window_preview_btn"], "clicked")
    connect_widget(apply_scale, builder["scale_window_apply_btn"], "clicked")
    connect_widget(cancel_scale, builder["scale_window_cancel_btn"], "clicked")

    connect_widget(scaleset, builder["slider_scale_adjustment"], "value-changed")

    global originalImage = CVProcessing.defaultimage()
    global processedImage = copy(originalImage)
    redrawImage(originalImage)

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

set_size!(w::Gtk.GtkWidget, width::Int, height::Int) = (@sigatom ccall(
    (:gtk_widget_set_size_request, Gtk.libgtk),
    Nothing,
    (Ptr{GObject}, Cint, Cint),
    w,
    width,
    height,
))

set_value!(w::Gtk.GObject, value::Float64) = (@sigatom ccall(
    (:gtk_adjustment_set_value, Gtk.libgtk),
    Nothing,
    (Ptr{GObject}, Cdouble),
    w,
    value,
))

set_sensitive!(w::Gtk.GtkWidget, state::Bool) = (@sigatom ccall(
    (:gtk_widget_set_sensitive, Gtk.libgtk),
    Nothing,
    (Ptr{GObject}, Cint),
    w,
    state,
))

enable(w) = @sync set_sensitive!(w, true)

disable(w) = @sync set_sensitive!(w, false)

function redrawImage(img)
    global currentHeight, currentWidth = size(img)

    drawAreaFrame, canvas = ImageView.frame_canvas(:none)
    set_size!(winDraw, currentWidth, currentHeight)

    empty!(winDraw)
    push!(winDraw, drawAreaFrame)
    imshow!(canvas, img)
    showall(winDraw)
end

function open_file(w)
    path = open_dialog("Open image file", GtkNullContainer(), image_filters)
    global originalImage = CVProcessing.open_file(path)
    global processedImage = copy(originalImage)
    redrawImage(originalImage)
end

function save_file(w)
    path = save_dialog("Save image file", GtkNullContainer(), image_filters)
    CVProcessing.save_file(path, processedImage)

end

function resize_image(w)
    set_value!(widthSlider, convert(Float64, currentWidth))
    set_value!(heightSlider, convert(Float64, currentHeight))

    show(winEditResize)
end

widthset(widget) = global currentWidth = Gtk.GAccessor.value(widget)

function preview_resize(w)
    disable(w)
    @sync redrawImage(CVProcessing.resize_image(
        processedImage,
        currentWidth,
        currentHeight,
    ))
    enable(w)
end

function apply_resize(widget)
    hide(winEditResize)
    global processedImage =
        CVProcessing.resize_image(processedImage, currentWidth, currentHeight)
    redrawImage(processedImage)
end

heightset(widget) = global currentHeight = Gtk.GAccessor.value(widget)

function cancel_resize(w)
    hide(winEditResize)
    redrawImage(processedImage)
end

function crop_image(w)
    show(winEditCrop)
end

function preview_crop(w)
    disable(w)
    @sync redrawImage(CVProcessing.resize_image(
        processedImage,
        currentWidth,
        currentHeight,
    ))
    enable(w)
end

function apply_crop(w)
    hide(winEditCrop)
    global processedImage =
        CVProcessing.resize_image(processedImage, currentWidth, currentHeight)
    redrawImage(processedImage)
end

function cancel_crop(widget)
    hide(winEditCrop)
    redrawImage(processedImage)
end

function scale_image(w)
    global currentScale = 0
    set_value!(widthSlider, convert(Float64, currentWidth))
    set_value!(heightSlider, convert(Float64, currentHeight))
    set_value!(scaleSlider, convert(Float64, currentScale))
    show(winEditScale)
end

function preview_scale(w)
    disable(w)

    @sync redrawImage(CVProcessing.scale_image(
        processedImage,
        currentWidth,
        currentHeight,
        currentScale == 0 ? 0 : currentScale / 100,
    ))
    
    enable(w)
end

function apply_scale(widget)
    hide(winEditScale)
    global processedImage = CVProcessing.scale_image(
        processedImage,
        currentWidth,
        currentHeight,
        currentScale == 0 ? 0 : currentScale / 100,
    )
    redrawImage(processedImage)
end

function cancel_scale(widget)
    hide(winEditScale)
    redrawImage(processedImage)
end

scaleset(widget) = global currentScale = Gtk.GAccessor.value(widget)
end
