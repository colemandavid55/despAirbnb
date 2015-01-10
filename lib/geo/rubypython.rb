
def python_baby(coord)
  coord = ["26.062951", "-80.238853"]

  pythonPortal = IO.popen("python python_function.py", "w+")
  pythonPortal.puts coord
  pythonPortal.close_write
  result = []
  temp = pythonPortal.gets

  while temp!= nil
      result<<temp
      temp = pythonPortal.gets
  end 

  corner1 = [] 
  corner2 = []


  corner1 << result[0].gsub(/[()]/, "").split("=")[0].split(",")[0].gsub(/[deg]/, "").to_f
  corner1 << result[0].gsub(/[()]/, "").split("=")[0].split(",")[1].strip.gsub(/[deg]/, "").to_f
  corner2 << result[1].gsub(/[()]/, "").split("=")[0].split(",")[0].gsub(/[deg]/, "").to_f
  corner2 << result[1].gsub(/[()]/, "").split("=")[0].split(",")[1].gsub(/[deg]/, "").to_f

  box = []
  box << corner1
  box << corner2

  box
end