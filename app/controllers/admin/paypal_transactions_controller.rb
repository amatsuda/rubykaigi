# -*- coding: utf-8 -*-
require 'fastercsv'
class Admin::PaypalTransactionsController < AdminController
  def download
    respond_to do |wants|
      item_number = params[:id]
      wants.csv {
        paypal_txns = PaypalTransaction.find_all_by_item_number(item_number)
        csv = FasterCSV.generate(:col_sep => "\t") do |c|
          c << ["row", "item", "4digits", "txn_id", "email", "last_name", "first_name", "student?", "memo"]
          paypal_txns.each_with_index do |txn, idx|
            memo = txn.memo && txn.memo.gsub(/\n/, "/")
            is_student = (txn.memo =~ /学生/ ? "学" : " ")
            c << [idx + 1, txn.item_number, txn.txn_id[0,4], txn.txn_id, txn.payer_email, txn.last_name, txn.first_name, is_student, memo]
          end
        end
        send_data(csv, :filename => "#{item_number}.csv",
          :type => 'text/csv', :disposition => 'attachement')
      }
    end
  end
end
