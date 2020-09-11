"""
The code can be used to scrap the companies’ finance data from finance.yahoo page. You just need to know short company code, 
for example from page https://finance.yahoo.com/gainers, column Symbol. And you just need to add company’s short name in companies_list list.

Financial results takes from page like: https://finance.yahoo.com/quote/BNKXF/financials?p=BNKXF

The code also can filter the companies by their grows’ criteria – for example you want to see only such companies, 
which grew 10% in 2018 year and 5% in 2019 year. 
"""
import pandas as pd
import requests
from bs4 import BeautifulSoup
import numpy as np

pd.options.display.float_format = '{:.0f}'.format

companies_name_file = 'companies_list.csv'
company_list = list(pd.read_csv(companies_name_file).iloc[:, 0])

year = ['ttm/2020', '2019/2018', '2018/2017', '2017/2016']
grown = []
for i in range(4):
    grown.append(int(input('Please, enter the percentage change in Total Revenue {}:'.format(year[i]))))
    
grown_np = np.array(grown) / 100 + 1


companies_name_file = 'companies_list.csv'
companies_list = list(pd.read_csv(companies_name_file).iloc[:, 0])
companies_without_financial_report = []

possible_argument = ['Total Revenue', 'Cost of Revenue', 'Gross Profit', 'Operating Expense', 'Operating Income',
                     'Net Non Operating Interest Income Expense', 'Other Income Expense', 'Pretax Income',
                     'Tax Provision', 'Net Income Common Stockholders', 'Diluted NI Available to Com Stockholders',
                     'Basic EPS', 'Diluted EPS', 'Basic Average Shares', 'Diluted Average Shares',
                      'Total Operating Income as Reported', 'Total Expenses',
                      'Net Income from Continuing & Discontinued Operation', 'Normalized Income', 'Interest Expense',
                        'Net Interest Income', 'EBIT', 'EBITDA', 'Reconciled Cost of Revenue', 'Reconciled Depreciation',
                        'Net Income from Continuing Operation Net Minority Interest', 'Total Unusual Items Excluding Goodwill',
                     'Total Unusual Items', 'Normalized EBITDA', 'Tax Rate for Calcs', 'Tax Effect of Unusual Items']

# You can choice only one collumn
criteria = possible_argument[0]


def company_financal_data(company, criteria):
    
    global companies_without_financial_report
    
    url_is = 'https://finance.yahoo.com/quote/' + company + '/financials?p=' + company
    response = requests.get(url_is)
    soup_is = BeautifulSoup(response.text, "lxml")
    features = soup_is.find_all('div', class_='D(tbr)')

    headers = []
    temp_list = []
    final = []
    index = 0
    try:
        for item in features[0].find_all('div', class_='D(ib)'):
            headers.append(item.text)
        while index <= len(features)-1:
            temp = features[index].find_all('div', class_='D(tbc)')
            for line in temp:
                temp_list.append(line.text)
            final.append(temp_list)
            temp_list = []
            index+=1
    except IndexError:
        companies_without_financial_report.append(company)
        return None
        
    df = pd.DataFrame(final[1:])
    df.columns = headers
    df['Company'] = company
    df = df[df['Breakdown'] == criteria]
    return(df)

or_is = False
for company in companies_list:
    row = company_financal_data(company, criteria)
    if not or_is:
        db = row
        or_is = True
    else:
        db = pd.concat([db, row])

for col in list(db.columns):
    db[col] = db[col].str.replace(',','')

convert_dict = {'ttm': float,
               '12/31/2019': float,
                '12/31/2018': float,
                '12/31/2017': float, 
                '12/31/2016':float
               } 
db = db.astype(convert_dict)  

result = db[(db['ttm'] > db['12/31/2019'] * grown_np[0]) &
            (db['12/31/2019'] > db['12/31/2018'] * grown_np[1]) & 
            (db['12/31/2018'] > db['12/31/2017'] * grown_np[2]) &
           (db['12/31/2017'] > db['12/31/2016'] * grown_np[3])]


# Prints companies that meet the criteria
print("Companies:", end = " ")
x = 1
for r in result['Company']:
    print(r, end = " ")
    if x % 8 == 0 and x > 0:
        print()
    x += 1
    
print()    
print("Companies without financial reports:", end = " ")
x = 1
for r in companies_without_financial_report:
    print(r, end = " ")
    if x % 8 == 0 and x > 0:
        print()
    x += 1