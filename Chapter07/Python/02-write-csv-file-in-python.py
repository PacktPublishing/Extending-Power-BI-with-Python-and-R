import csv

with open(r'D:\<your-path>\Chapter07\Python\example-write.csv', mode='w', newline='') as csv_file:
    csv_writer = csv.writer(csv_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)

    csv_writer.writerow(['Col1', 'Col2', 'Col3'])
    csv_writer.writerow(['A', 23, 3.5])
    csv_writer.writerow(['B', 27, 4.8])
    csv_writer.writerow(['C,D', 18, 2.1])
    csv_writer.writerow(['E"F', 19, 2.5])
    csv_writer.writerow(['G\r\nH', 21, 3.1])
