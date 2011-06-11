import csv
from operator import itemgetter
from itertools import groupby
from xml.dom.minidom import Document

def main():
    """Main function to convert csv to xml."""
    csvreader = CSVUtils('company_list')
    csvreader()

class CSVUtils(object):
    def __init__(self, filename):
        assert filename is not None, \
            "filename required, not given"
        self.filename = filename

    def __call__(self):
        filecontent = csv.reader(open(self.filename+'.csv', 'U'))
        data = []
        for row in filecontent:
            data.append(row)
        data.pop(0)
        data.sort(key=itemgetter(1))
        for row in data:
            row[2] = self.getoffice(row)
            row[3] = self.getdepartment(row[1])
            row[1] = self.getcompany(row[1])
        self.csv2xml(data)

    def csv2xml(self, data):
        doc = Document()
        hierarchy = doc.createElement('hierarchy')
        doc.appendChild(hierarchy)
        for company, details in groupby(data, itemgetter(1)):
            companynode = doc.createElement('company')
            companynode.setAttribute('name', company)
            hierarchy.appendChild(companynode)
            for office, dept in groupby(details, itemgetter(2)):
                officenode = doc.createElement('office')
                officenode.setAttribute('name', office)
                companynode.appendChild(officenode)             
                for item in dept:
                    departmentnode = doc.createElement('department')
                    departmentnode.setAttribute('id', item[0])
                    departmentnode.setAttribute('name', item[3])
                    officenode.appendChild(departmentnode)
        f = open(self.filename+'.xml', 'w')
        doc.writexml(f, addindent="  ", newl="\n")
        f.close()

    def getcompany(self, name):
        company = name.split('(')
        return company[0].strip()

    def _findnextcolumn(self, row):
        """find office name in next column"""
        if row[2] and row[2] != 'Lettings':
            return row[2].strip()
        elif row[3] and row[3] != 'Lettings':
            return row[3].strip()
        else:
            return "Head Office"

    def getoffice(self, row):
        office = row[1].split('(')
        if office.__len__() < 2:
            return self._findnextcolumn(row)
        office = office[1]
        office = office.split('Lettings')
        if office[0] and 'Sales' not in office[0]:
            office = office[0].replace(')','')
            return office.strip()
        else:
            return self._findnextcolumn(row)

    def getdepartment(self, name):
        if 'Lettings' in name:
            return 'Lettings'
        else:
            return 'Sales'
    
if __name__ == '__main__':
    main()
