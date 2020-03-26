module CVUI
export initUI

include("CVProcessing.jl")

using Gtk, ImageView, .CVProcessing

function open_file(w)
    path = open_dialog("Open image file")
    processedImage = CVProcessing.open_file(path)
    imshow!(canvas, processedImage)
end

function save_file(w)
    path = save_dialog("Save image file")
    CVProcessing.save_file(path, processedImage)
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

    openFileBtn = builder["open_image_btn"]
    saveFileBtn = builder["save_image_btn"]

    signal_connect(open_file, openFileBtn, "clicked", true)
    signal_connect(save_file, saveFileBtn, "clicked", true)

    showall.([winDraw, winToolbar])

    if !isinteractive()
        c = Condition()
        signal_connect(winDraw, :destroy) do widget
            notify(c)
        end
        wait(c)
    end
end
end
