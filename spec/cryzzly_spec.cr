require "./spec_helper"
require "../src/cryzzly/dataframe"

describe Cryzzly do
  
  filename = "./spec/sample.csv"
  
  df = Dataframe(Any).load_csv(filename, index_col: 0, index_type: "datetime" )
  it "loads data from CSV file" do
    df.should_not eq(nil)
  end

  it "returns data" do
    df.data.should_not eq(nil)
  end

  it "returns sum of selected cols" do
    df.sum("col1", "col2", "col3", "col4").data.should eq([3198769.0, 3202599.0, 31.45, 31.179999999999993])
  end


  it "calculates mean of rows" do
    df.mean("col1", "col2", "col3", "col4").data.should eq([66641.02083333333, 66720.8125, 0.6552083333333333, 0.6495833333333332])
  end

  it "returns the length of cols" do
    df.length.should eq(5)
  end

  it "returns shape of dataset" do
    df.shape.should eq([5, 48])
  end

  it "returns the minimun value of selected column" do
    df.min("col1", "col2", "col3", "col4").data.should eq([66464.0, 66534.0, 0.6, 0.59])
  end

  it "returns the minimun value of selected column" do
    df.max("col1", "col2", "col3", "col4").data.should eq([66817.0, 66905.0, 0.73, 0.7])
  end

  it "calculates standard deviation of column" do
    df.std("col1", "col2", "col3", "col4").data.should eq([22.174517561668804,
      24.76969886873622,
      0.003616236247551984,
      0.0028565227501670784])
  end

  it "plots and save the series" do
    df.plot("col1", "col2", filename: "spec/my_plot")
    File.open("my_plot.png").should_not eq(nil)
  end

  it "exports to csv" do
    df.to_csv("col1", "col2", "col3", "col4", filename: "spec/my_csvsheet")
    File.open("my_csvsheet.csv").should_not eq(nil)
  end
end
