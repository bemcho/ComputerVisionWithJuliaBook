__precompile__()
module ComputerVisionWithJuliaBook

using Gtk, Images, ImageView, TestImages

function drawToCanvas()
  imshow!(canvas,processedImage)
end

function open_file(w)
  @async println("Open file handler widget is: ", w)
  global current_image_file_path = open_dialog("Choose image file")
  @async println("Choosen file is: ", current_image_file_path)
  processedImage = load(current_image_file_path)
  imshow!(canvas,processedImage)
end

function save_file(w)
  @async println("Save file handler widget is: ", w)
  path = save_dialog("Choose image file")
  @async println("Choosen file is: ", path)
  save(path, processedImage)
end

function initUI()
  builder = GtkBuilder(
    filename = joinpath(@__DIR__, "../resource/gtk", "ComputerVisionWithJuliaBook.glade"),
  )

  global winDraw = builder["main_window_draw"]
  mainGrid = builder["main_grid"]
  global  drawAreaFrame,canvas = ImageView.frame_canvas(:auto)
  push!(mainGrid, drawAreaFrame)
  global processedImage = testimage("lighthouse")

  imshow!(canvas,processedImage)

  openFileBtn = builder["open_image_btn"]
  saveFileBtn = builder["save_image_btn"]

  signal_connect(open_file, openFileBtn, "clicked", true)
  signal_connect(save_file, saveFileBtn, "clicked", true)

  showall(winDraw)

  if !isinteractive()
    c = Condition()
    signal_connect(winDraw, :destroy) do widget
      notify(c)
    end
    wait(c)
  end
end



function julia_main()::Cint
  # do something based on ARGS?
  initUI()
  return 0 # if things finished successfully
end
#comment when building native app
julia_main()
end
