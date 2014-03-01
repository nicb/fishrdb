#
# $Id: test_csv_db.rb 371 2009-04-17 22:26:58Z nicb $
#

csv_test_path = File.dirname(__FILE__)
require csv_test_path + '/../csv/fis_reader'

@fr = FisReader.new(csv_test_path + '/ScelsiDataBase.csv')

