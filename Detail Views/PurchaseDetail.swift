//
//  PurchaseDetail.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 8/30/21.
//

import SwiftUI

struct PurchaseDetail: View {
    @ObservedObject var purchase: Purchase

    let dateFormat = Date.FormatStyle.dateTime
        .year().month(.defaultDigits).day()

    var body: some View {
        List {
            Section("Catalog") {
                if !purchase.manufacturer!.isEmpty {
                    PurchaseDetailRow(title: "Manufacturer") {
                        Text(purchase.manufacturer!)
                    }
                }

                if !purchase.catalogNumber!.isEmpty {
                    PurchaseDetailRow(title: "Number") {
                        Text(purchase.catalogNumber!)
                    }
                }

                if !purchase.catalogDescription!.isEmpty {
                    PurchaseDetailRow(title: "Description") {
                        Text(purchase.catalogDescription!)
                    }
                }
                
                if purchase.catalogYear > 0 {
                    PurchaseDetailRow(title: "Year") {
                        Text(purchase.catalogYear, format: .number.grouping(.never))
                    }
                }
                
                if !purchase.limitedEdition!.isEmpty || purchase.limitedEditionNumber > 0 || purchase.limitedEditionCount > 0 {
                    PurchaseDetailRow(title: "Limited Edition") {
                        OptionalText(purchase.limitedEdition!)
                        Text("\(purchase.limitedEditionNumber) of \(purchase.limitedEditionCount)")
                    }
                }
            }
            
            Section("Purchase") {
                if let date = purchase.date {
                    PurchaseDetailRow(title: "Date") {
                        Text(date, format: dateFormat)
                    }
                }
                
                if !purchase.store!.isEmpty {
                    PurchaseDetailRow(title: "Store") {
                        Text(purchase.store!)
                    }
                }
                
                if let price = purchase.price {
                    PurchaseDetailRow(title: "Price") {
                        Text(price, format: .currency(code: purchase.priceCurrencyCode!))
                    }
                }
                
                if let condition = purchase.condition {
                    PurchaseDetailRow(title: "Condition") {
                        Text(condition.description)
                    }
                }
                
                if let valuation = purchase.valuation {
                    PurchaseDetailRow(title: "Valuation") {
                        Text(valuation, format: .currency(code: purchase.valuationCurrencyCode!))
                    }
                }
            }
            
            if !purchase.notes!.isEmpty {
                Section(header: Text("Notes")) {
                    Text(purchase.notes!)
                }
            }
            
            PurchaseItems(purchase: purchase)
        }
    }
}

struct PurchaseDetailRow<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
            content
        }
    }
}

struct PurchaseDetail_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseDetail(purchase: PreviewData.shared.purchases["R1234M"]!)
            .environment(\.managedObjectContext, PreviewData.shared.viewContext)
    }
}
