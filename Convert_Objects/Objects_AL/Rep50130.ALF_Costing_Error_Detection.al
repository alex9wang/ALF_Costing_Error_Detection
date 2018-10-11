report 60010 "Costing Error Detection New"
{
    // version NAVDIAG17.10.06

    DefaultLayout = RDLC;
    RDLCLayout = './Costing Error Detection New.rdlc';
    Caption = 'Costing Error Detection';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem(ErrorGroup;"Integer")
        {
            DataItemTableView = SORTING(Number);
            PrintOnlyIfDetail = true;
            column(CompanyName;CompanyName)
            {
            }
            column(Today;Format(Today,0,4))
            {
            }
            column(UserID;UserId)
            {
            }
            column(ShowCaption;ShowCaption)
            {
            }
            column(Number_ErrorGroup;Number)
            {
            }
            dataitem(Item;Item)
            {
                PrintOnlyIfDetail = true;
                RequestFilterFields = "No.";
                column(No_Item;"No.")
                {
                }
                column(Description_Item;Description)
                {
                    DecimalPlaces = 0:0;
                    IncludeCaption = true;
                }
                dataitem(ItemCheck;Item)
                {
                    DataItemLink = "No."=FIELD("No.");
                    DataItemTableView = SORTING("No.");
                    dataitem(ItemErrors;"Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(ErrorText_ItemErrors;ErrorText[Number])
                        {
                        }
                        column(Number_ItemErrors;Number)
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            SetRange(Number,1,CompressArray(ErrorText));
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        ClearErrorText;

                        case ErrorGroupIndex of
                          0:
                            CheckItem("No.");
                        end;

                        if CompressArray(ErrorText) = 0 then
                          CurrReport.Skip;
                    end;
                }
                dataitem("Item Ledger Entry";"Item Ledger Entry")
                {
                    DataItemLink = "Item No."=FIELD("No.");
                    DataItemTableView = SORTING("Item No.");
                    column(EntryNo_ItemLedgerEntry;"Entry No.")
                    {
                        IncludeCaption = true;
                    }
                    column(EntryType_ItemLedgerEntry;"Entry Type")
                    {
                        IncludeCaption = true;
                    }
                    column(EntryTypeFormat_ItemLedgerEntry;Format("Entry Type"))
                    {
                    }
                    column(ItemNo_ItemLedgerEntry;"Item No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Quantity_ItemLedgerEntry;Quantity)
                    {
                        IncludeCaption = true;
                    }
                    column(RemainingQuantity_ItemLedgerEntry;"Remaining Quantity")
                    {
                        IncludeCaption = true;
                    }
                    column(Positive_ItemLedgerEntry;Positive)
                    {
                        IncludeCaption = true;
                    }
                    column(Open_ItemLedgerEntry;Open)
                    {
                        IncludeCaption = true;
                    }
                    column(PostingDate_ItemLedgerEntry;"Posting Date")
                    {
                        IncludeCaption = true;
                    }
                    dataitem(Errors;"Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(ErrorText_Errors;ErrorText[Number])
                        {
                        }
                        column(Number_Errors;Number)
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            SetRange(Number,1,CompressArray(ErrorText))
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Window.Update(3,"Entry No.");
                        ClearErrorText;
                        case ErrorGroupIndex of
                          0:
                            CheckBasicData;
                          1:
                            CheckItemLedgEntryQty;
                          2:
                            CheckApplicationQty;
                          4:
                            CheckValuedByAverageCost;
                          5:
                            CheckValuationDate;
                          6:
                            CheckRemainingExpectedAmount;
                          7:
                            CheckOutputCompletelyInvdDate;

                        end;

                        if CompressArray(ErrorText) = 0 then
                          CurrReport.Skip;
                    end;

                    trigger OnPreDataItem()
                    begin
                        case ErrorGroupIndex of
                          0:;//Basic Data Test
                          1://Qty. Check Item Entry <--> Item Appl. Entry
                            begin
                              ItemApplEntry.Reset;
                              ItemApplEntry.SetCurrentKey("Item Ledger Entry No.");
                            end;
                          2://Application Qty. Check
                            begin
                              SetRange(Positive,true);
                              ItemApplEntry.Reset;
                              ItemApplEntry.SetCurrentKey("Inbound Item Entry No.");
                            end;
                          3://Check Related Inb. - Outb. Value Entry
                            begin
                              SetRange(Positive,true);
                              ItemApplEntry.Reset;
                              ItemApplEntry.SetCurrentKey("Item Ledger Entry No.");
                            end;
                          4://Check Valued By Average Cost
                            begin
                              SetRange(Positive,false);
                              ItemApplEntry.Reset;
                              ItemApplEntry.SetCurrentKey("Item Ledger Entry No.");
                            end;
                          5://Check Valuation Date
                            begin
                              SetRange(Positive,true);
                              ItemApplEntry.Reset;
                              ItemApplEntry.SetCurrentKey("Inbound Item Entry No.");
                            end;
                          6:// Check remaining expected cost on closed item ledger entry
                            begin
                              ItemApplEntry.Reset;
                              ItemApplEntry.SetCurrentKey("Outbound Item Entry No.","Item Ledger Entry No.");
                            end;
                          7:// Check Output Completely Invd. Date' in Table 339
                            begin

                            end;
                        end;
                    end;
                }
                dataitem("Value Entry";"Value Entry")
                {
                    DataItemLink = "Item No."=FIELD("No.");
                    DataItemTableView = SORTING("Item No.","Posting Date","Item Ledger Entry Type","Entry Type","Variance Type","Item Charge No.","Location Code","Variant Code");
                    column(EntryNo_ValueEntry;"Entry No.")
                    {
                    }
                    column(ItemNo_ValueEntry;"Item No.")
                    {
                    }
                    column(ItemLedgerEntryType_ValueEntry;"Item Ledger Entry Type")
                    {
                    }
                    column(PostingDate_ValueEntry;"Posting Date")
                    {
                    }
                    column(ItemLedgerEntryQuantity_ValueEntry;"Item Ledger Entry Quantity")
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        ItemLedgEntry: Record "Item Ledger Entry";
                    begin
                        if ItemLedgEntry.Get("Item Ledger Entry No.") then
                          CurrReport.Skip;

                        if Item2.Get("Item No.") then begin
                          ItemTemp := Item2;
                          if ItemTemp.Insert then;
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        if (ErrorGroupIndex <> 8) or (Item."No." = '') then
                          CurrReport.Break;

                        if not CheckItemLedgEntryExists then
                          CurrReport.Break;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if Type = Type::Service then
                      CurrReport.Skip;

                    Window.Update(2,"No.");
                end;

                trigger OnPreDataItem()
                begin
                    if ErrorGroupIndex in [3,4] then begin
                      if CostingMethodFiltered then
                        CurrReport.Break
                      else
                        SetRange("Costing Method","Costing Method"::Average);
                    end else
                      SetRange("Costing Method");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                ErrorGroupIndex := Number;
                case ErrorGroupIndex of
                  0:
                    if not BasicDataTest then
                      CurrReport.Skip
                    else
                      Window.Update(1,Text023);
                  1:
                    if not QtyCheckItemLedgEntry then
                      CurrReport.Skip
                    else
                      Window.Update(1,Text002);
                  2:
                    if not ApplicationQtyCheck then
                      CurrReport.Skip
                    else
                      Window.Update(1,Text003);
                  4:
                    if not ValuedByAverageCheck then
                      CurrReport.Skip
                    else
                      Window.Update(1,Text006);
                  5:
                    if not ValuationDateCheck then
                      CurrReport.Skip
                    else
                      Window.Update(1,Text005);
                  6:
                    if not RemExpectedOnClosedEntry then
                      CurrReport.Skip
                    else
                      Window.Update(1,Text031);
                  7:
                    if not OutputCompletelyInvd then
                      CurrReport.Skip
                    else
                      Window.Update(1,Text033);
                  8:
                    if not CheckItemLedgEntryExists then
                      CurrReport.Skip
                    else
                      Window.Update(1,Text036);
                end;
            end;

            trigger OnPreDataItem()
            begin
                SetRange(Number,0,8);
            end;
        }
        dataitem(Summary;"Integer")
        {
            DataItemTableView = SORTING(Number);
            column(ItemSummaryCaption;Text047)
            {
            }
            column(No_Summary;ItemTemp."No.")
            {
            }
            column(Description_Summary;ItemTemp.Description)
            {
            }
            column(Number_Summary;Number)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then
                  ItemTemp.FindFirst
                else
                  ItemTemp.Next;
            end;

            trigger OnPreDataItem()
            begin
                SetRange(Number,1,ItemTemp.Count);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                field(BasicDataTest;BasicDataTest)
                {
                    Caption = 'Basic Data Test';
                }
                field(QtyCheckItemLedgEntry;QtyCheckItemLedgEntry)
                {
                    Caption = 'Item Ledger Entry - Item Application Entry Quantity Check';
                }
                field(ApplicationQtyCheck;ApplicationQtyCheck)
                {
                    Caption = 'Application Quantity Check';
                }
                field(ValuedByAverageCheck;ValuedByAverageCheck)
                {
                    Caption = 'Check Valued By Average Cost';
                }
                field(ValuationDateCheck;ValuationDateCheck)
                {
                    Caption = 'Check Valuation Date';
                }
                field(RemExpectedOnClosedEntry;RemExpectedOnClosedEntry)
                {
                    Caption = 'Check Expected Cost on completely invoiced entry';
                }
                field(CheckItemLedgEntryExists;CheckItemLedgEntryExists)
                {
                    Caption = 'Check Item ledg. Entry No. from Value Entries';
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        ReportName = 'Costing Error Detection';
        PageNoCaption = 'Page';
    }

    trigger OnPostReport()
    begin
        Window.Close;
    end;

    trigger OnPreReport()
    var
        TempItem: Record Item temporary;
    begin
        if not (BasicDataTest or QtyCheckItemLedgEntry or ApplicationQtyCheck or
                ValuedByAverageCheck or ValuationDateCheck or RemExpectedOnClosedEntry or
                OutputCompletelyInvd or CheckItemLedgEntryExists)
        then
          Error(Text000);

        if not "Item Ledger Entry".Find('-') then
          Error(Text001);

        Window.Open(Text020 + Text021 + Text022);

        TempItem.SetRange("Costing Method",TempItem."Costing Method"::Average);
        if Item.GetFilter("Costing Method") <> '' then
          if Item.GetFilter("Costing Method") <> TempItem.GetFilter("Costing Method") then
            CostingMethodFiltered := true;
    end;

    var
        ItemApplEntry: Record "Item Application Entry";
        Item2: Record Item;
        ItemTemp: Record Item temporary;
        ErrorGroupIndex: Integer;
        ErrorIndex: Integer;
        BasicDataTest: Boolean;
        QtyCheckItemLedgEntry: Boolean;
        ApplicationQtyCheck: Boolean;
        ValuedByAverageCheck: Boolean;
        ValuationDateCheck: Boolean;
        Text000: Label 'You must select one or more of the data checks.';
        Text001: Label 'There are no Item Ledger Entries to check.';
        Text002: Label 'Item Ledger Entry - Item Appl. Entry Qty. Check';
        Text003: Label 'Application Quantity Check';
        Text005: Label 'Check Valuation Date';
        Text006: Label 'Check Valued By Average Cost';
        CostingMethodFiltered: Boolean;
        ErrorText: array [20] of Text[250];
        Text007: Label 'An %1 exists even though the %2 and %3 are the same in this negative Item Ledger Entry.';
        Text008: Label 'There is more than one %1 with the same combination of %2, %3 and %4.';
        Text009: Label 'The %1 is greater than the %1.';
        Text010: Label 'The summed %1 of the linked Item Application Entries is not the same as the difference between %2 and %3.';
        Text011: Label 'The summed %1 of the linked Item Application Entries is not the same as the %2.';
        Text012: Label 'The sign of the %1 in one or more of the linked Item Application Entries must be the opposite (positive must be negative or negative must be positive).';
        Text013: Label 'The summed %1 of the linked Item Application Entries is different than the %2 of the %3.';
        Text014: Label 'There are no Value Entries for this %1.';
        Text015: Label 'The summed %1 of the Item Application Entries for this transfer do not add up to zero as they should.';
        Text016: Label 'The Value Entries linked to the Item Application Entries do not all have the same %1 or %2.';
        Text017: Label 'The %1 in Value Entries applied to this %2 is earlier than the %1 in the %3 for this %2.';
        Text018: Label 'The value of the %1 field in the corresponding Value Entries is not correct.';
        Text019: Label 'The value of the %1 field in the corresponding Item Application Entries is not correct.';
        Window: Dialog;
        Text020: Label 'Function          #1##########################\';
        Text021: Label 'Item              #2##########################\';
        Text022: Label 'Item Ledger Entry #3##########################';
        Text023: Label 'Basic Data Test';
        Text024: Label 'The %1 must not be 0.';
        Text025: Label '%1 must be %2.';
        Text026: Label '%1 must be %2.';
        Text027: Label 'The linked Value Entries do not all have the same value of %1.';
        Text028: Label 'A linked %1 should not have the %2 %3 for a positive entry with %4 Consumption.';
        Text029: Label '%1 of Value Entries must not be Yes for any %2 other than Average.';
        Text030: Label 'There are no Item Application Entries for this %1.';
        RemExpectedOnClosedEntry: Boolean;
        Text031: Label 'Check Expected Cost on a closed entry';
        Text032: Label 'Expected Cost Amount was not 0 on an invoiced entry';
        OutputCompletelyInvd: Boolean;
        Text033: Label 'Check Output Completely Invoiced Date';
        Text034: Label 'At least one linked Item Application Entry has an unspecified %1.';
        Text035: Label 'A blank date in %1 was found on an Item Ledger Entry which has been invoiced';
        CheckItemLedgEntryExists: Boolean;
        Text036: Label 'Value Entries with missing Item Ledger Entry';
        Text037: Label 'Check Exptd. Cost on Completely Invoiced entries';
        Text038: Label 'Check Completely Invoiced date';
        Text039: Label '%1 was different to %2 on a linked Item Application Entry.';
        Text040: Label '%1 was specified on a linked Item Application Entry but the Item Ledger Entry is not Completely Invoiced.';
        Text041: Label '%1 was not equal to %2 on a linked Item Application Entry.';
        Text042: Label 'The summed %1 of the linked Value Entries is not the same as the %2.';
        Text043: Label '%1 or %2 was not 0 on a linked Value Entry. However this could be because report 1002 has not been run yet.';
        Text044: Label '%1 must be 0 when %2 is true.';
        Text045: Label '%1 or %2 is not 0 on a Completely Invoiced Item Ledger Entry';
        Text046: Label '%1 must equal %2 when %3 is true.';
        Text047: Label 'Item Summary';
        Text048: Label '%1 must be 0 on %2 %3 when %4 is true on a %5';
        Text049: Label '%1 must be false when %2 > 0 and %3 is %4 on %5 %6';
        Text050: Label '%1 on a %2 is not equal to %3 on %4 %5';
        Text051: Label '%1 on a %2 must not be smaller than or equal to 0.';
        Text052: Label '%1 must not be blank on a %2.';

    procedure ShowCaption(): Text[50]
    begin
        //ShowCaption
        case ErrorGroupIndex of
          0:
            exit(Text023);
          1:
            exit(Text002);
          2:
            exit(Text003);
          4:
            exit(Text006);
          5:
            exit(Text005);
          6:
            exit(Text037);
          7:
            exit(Text038);
          8:
            exit(Text036);
        end;
    end;

    procedure ClearErrorText()
    begin
        //ClearErrorText
        if CompressArray(ErrorText) <> 0 then
          for ErrorIndex := 1 to CompressArray(ErrorText) do
            ErrorText[ErrorIndex] := '';
        ErrorIndex := 1;
    end;

    procedure CheckBasicData()
    begin
        //CheckBasicData
        BasicCheckItemLedgEntry;
        BasicCheckValueEntry;
    end;

    procedure BasicCheckItemLedgEntry()
    var
        ValueEntry: Record "Value Entry";
    begin
        //BasicCheckItemLedgEntry
        with "Item Ledger Entry" do begin
          if "Entry No." <= 0 then
            AddError(StrSubstNo(Text051,FieldCaption("Entry No."),TableCaption),"Item No.");
          if Quantity = 0 then begin
            AddError(StrSubstNo(Text024,FieldCaption(Quantity)),"Item No.");
          end else begin
            if (Quantity * "Remaining Quantity") < 0 then begin
              AddError(StrSubstNo(Text009,FieldCaption("Remaining Quantity"),FieldCaption(Quantity)),"Item No.");
            end else
              if Abs("Remaining Quantity") > Abs(Quantity) then begin
                AddError(StrSubstNo(Text009,FieldCaption("Remaining Quantity"),FieldCaption(Quantity)),"Item No.");
              end;
            if (Quantity > 0) <> Positive then begin
              AddError(StrSubstNo(Text025,FieldCaption(Positive),not Positive),"Item No.");
            end;
          end;
          if ("Remaining Quantity" = 0) = Open then begin
            AddError(StrSubstNo(Text026,FieldCaption(Open),not Open),"Item No.");;
          end;

          if "Completely Invoiced" then begin
            if "Invoiced Quantity" <> Quantity then begin
              AddError(
                StrSubstNo(Text046,FieldCaption("Invoiced Quantity"),FieldCaption(Quantity),FieldCaption("Completely Invoiced")),
                "Item No.");
            end;

            ValueEntry.SetCurrentKey("Item Ledger Entry No.");
            ValueEntry.SetRange("Item Ledger Entry No.","Entry No.");
            ValueEntry.CalcSums("Invoiced Quantity");
            if "Invoiced Quantity" <> ValueEntry."Invoiced Quantity" then begin
              AddError(
                StrSubstNo(Text042,ValueEntry.FieldCaption("Invoiced Quantity"),FieldCaption("Invoiced Quantity")),
                "Item No.");
            end;
          end;
        end;
    end;

    procedure BasicCheckValueEntry()
    var
        ValueEntry: Record "Value Entry";
        ValuationDate: Date;
        ConsumptionDate: Date;
        ValuedByAverageCost: Boolean;
        Continue: Boolean;
        Compare: Boolean;
    begin
        //BasicCheckValueEntry
        with "Item Ledger Entry" do begin
          ValueEntry.SetCurrentKey("Item Ledger Entry No.");
          ValueEntry.SetRange("Item Ledger Entry No.","Entry No.");
          ValueEntry.SetRange(Inventoriable,true);
          if not ValueEntry.Find('-') then begin
            AddError(StrSubstNo(Text014,TableCaption),"Item No.");
          end else begin
            ValuedByAverageCost := ValueEntry."Valued By Average Cost";
            repeat
              if ValueEntry.Adjustment then begin
                if ValueEntry."Invoiced Quantity" <> 0 then begin
                  AddError(StrSubstNo(Text044,ValueEntry.FieldCaption("Invoiced Quantity"),ValueEntry.FieldCaption(Adjustment)),
                  "Item No.");
                  Continue := true;
                end;
                if ValueEntry."Item Ledger Entry Quantity" <> 0 then begin
                  AddError(
                    StrSubstNo(Text048,"Item Ledger Entry".FieldCaption(Quantity),
                      "Item Ledger Entry".TableCaption,"Item Ledger Entry"."Entry No.",
                      ValueEntry.FieldCaption(Adjustment),ValueEntry.TableCaption),
                      "Item Ledger Entry"."Item No.");
                end;
              end;
              if ("Entry Type" = "Entry Type"::Consumption) and Positive and
                 (ValueEntry."Valuation Date" = DMY2Date(31,12,9999))
              then begin
                ConsumptionDate := DMY2Date(31,12,9999);
                AddError(
                  StrSubstNo(Text028,ValueEntry.TableCaption,ValueEntry.FieldCaption("Valuation Date"),ConsumptionDate,
                  FieldCaption("Entry Type")),
                  "Item No.");
                Continue := true;
              end else begin
                if (not Compare) and (ValueEntry."Valuation Date" <> 0D) and
                   not (ValueEntry."Entry Type" in [ValueEntry."Entry Type"::Rounding,ValueEntry."Entry Type"::Revaluation])
                then begin
                  ValuationDate := ValueEntry."Valuation Date";
                  Compare := true;
                end;
                if Compare then
                  if (ValueEntry."Valuation Date" <> ValuationDate) and (ValueEntry."Valuation Date" <> 0D) and
                     not (ValueEntry."Entry Type" in [ValueEntry."Entry Type"::Rounding,ValueEntry."Entry Type"::Revaluation])
                  then begin
                    AddError(StrSubstNo(Text027,ValueEntry.FieldCaption("Valuation Date")),"Item No.");
                    Continue := true;
                  end;
              end;
              if (ValueEntry."Valued By Average Cost") and
                 (Item."Costing Method" <> Item."Costing Method"::Average)
              then begin
                AddError(StrSubstNo(Text029,ValueEntry.FieldCaption("Valued By Average Cost"),Item.FieldCaption("Costing Method")),
                "Item No.");
                Continue := true;
              end else
                if ValueEntry."Valued By Average Cost" <> ValuedByAverageCost then begin
                  AddError(StrSubstNo(Text027,ValueEntry.FieldCaption("Valued By Average Cost")),"Item No.");
                  Continue := true;
                end;

              if (ValueEntry."Valued By Average Cost") and
                 (Item."Costing Method" = Item."Costing Method"::Average) and
                 (not Correction)
               then
                if ValueEntry."Valued Quantity" > 0 then begin
                    AddError(StrSubstNo(Text049,
                      ValueEntry.FieldCaption("Valued By Average Cost"),
                      ValueEntry.FieldCaption("Valued Quantity"),
                      Item.FieldCaption("Costing Method"),
                      Format(Item."Costing Method"),
                      ValueEntry.TableCaption,
                      ValueEntry."Entry No."),
                      "Item No.");
                  end;

              if ValueEntry."Item Charge No." = '' then
                if ValueEntry."Item Ledger Entry Type" <> "Entry Type" then begin
                  AddError(StrSubstNo(Text050,
                    ValueEntry.FieldCaption("Item Ledger Entry Type"),
                    ValueEntry.TableCaption,
                    FieldCaption("Entry Type"),
                    "Item Ledger Entry".TableCaption,
                    "Item Ledger Entry"."Entry No."),
                    "Item Ledger Entry"."Item No.");
                end;
            until (ValueEntry.Next = 0) or Continue;
          end;
        end;
    end;

    procedure CheckItemLedgEntryQty()
    begin
        //CheckItemLedgEntryQty
        with "Item Ledger Entry" do begin
          if (not Positive) and Open then
            CheckNegOpenILEQty
          else
            CheckILEQty;
          SearchInbOutbCombination;
        end;
    end;

    procedure CheckNegOpenILEQty()
    var
        ApplQty: Decimal;
    begin
        //CheckNegOpenILEQty
        with "Item Ledger Entry" do begin
          if Quantity = "Remaining Quantity" then begin
            ItemApplEntry.SetRange("Item Ledger Entry No.","Entry No.");
            if ItemApplEntry.Find('-') then begin
              AddError(StrSubstNo(Text007,ItemApplEntry.TableCaption,FieldCaption("Remaining Quantity"),FieldCaption(Quantity)),
                "Item No.");
            end;
          end else begin
            ItemApplEntry.SetRange("Item Ledger Entry No.","Entry No.");
            if ItemApplEntry.Find('-') then begin
              ApplQty := 0;
              repeat
                ApplQty := ApplQty + ItemApplEntry.Quantity;
              until ItemApplEntry.Next = 0;
              if ApplQty <> (Quantity - "Remaining Quantity") then begin
                AddError(
                  StrSubstNo(
                    Text010,ItemApplEntry.FieldCaption(Quantity),FieldCaption(Quantity),FieldCaption("Remaining Quantity")),
                  "Item No.");
              end;
            end;
          end;
        end;
    end;

    procedure CheckILEQty()
    var
        ApplQty: Decimal;
    begin
        //CheckILEQty
        with "Item Ledger Entry" do begin
          ItemApplEntry.SetRange("Item Ledger Entry No.","Entry No.");
          if ItemApplEntry.Find('-') then begin
            ApplQty := 0;
            repeat
              ApplQty := ApplQty + ItemApplEntry.Quantity;
            until ItemApplEntry.Next = 0;
            if ApplQty <> Quantity then begin
              AddError(StrSubstNo(Text011,ItemApplEntry.FieldCaption(Quantity),FieldCaption(Quantity)),"Item No.");
            end;
          end else begin
            AddError(StrSubstNo(Text030,TableCaption),"Item No.");
          end;
        end;
    end;

    procedure SearchInbOutbCombination()
    var
        ItemApplEntry2: Record "Item Application Entry";
        Continue: Boolean;
    begin
        //SearchInbOutbCombination
        with "Item Ledger Entry" do begin
          if ItemApplEntry.Find('-') then
            repeat
              ItemApplEntry2.SetCurrentKey(
                "Item Ledger Entry No.","Inbound Item Entry No.","Outbound Item Entry No.");
              ItemApplEntry2.SetRange("Item Ledger Entry No.",ItemApplEntry."Item Ledger Entry No.");
              ItemApplEntry2.SetRange("Inbound Item Entry No.",ItemApplEntry."Inbound Item Entry No.");
              ItemApplEntry2.SetRange("Outbound Item Entry No.",ItemApplEntry."Outbound Item Entry No.");
              ItemApplEntry2.SetFilter("Entry No.",'<>%1',ItemApplEntry."Entry No.");
              if ItemApplEntry2.Find('-') then begin
                AddError(
                  StrSubstNo(
                    Text008,ItemApplEntry2.TableCaption,ItemApplEntry2.FieldCaption("Item Ledger Entry No."),
                    ItemApplEntry2.FieldCaption("Inbound Item Entry No."),ItemApplEntry2.FieldCaption("Outbound Item Entry No.")),
                  "Item No.");
                Continue := true;
              end;
            until (ItemApplEntry.Next = 0) or Continue;
        end;
    end;

    procedure CheckApplicationQty()
    var
        ApplQty: Decimal;
        Continue: Boolean;
    begin
        //CheckApplicationQty
        with "Item Ledger Entry" do begin
          ItemApplEntry.SetRange("Inbound Item Entry No.","Entry No.");
          if ItemApplEntry.Find('-') then begin
            repeat
              if ((ItemApplEntry."Item Ledger Entry No." = ItemApplEntry."Inbound Item Entry No.") and
                  (ItemApplEntry.Quantity < 0)) or
                 ((ItemApplEntry."Item Ledger Entry No." <> ItemApplEntry."Inbound Item Entry No.") and
                  (ItemApplEntry.Quantity > 0)) or
                 ((ItemApplEntry."Item Ledger Entry No." <> ItemApplEntry."Outbound Item Entry No.") and
                  (ItemApplEntry.Quantity < 0))
              then begin
                AddError(StrSubstNo(Text012,ItemApplEntry.FieldCaption(Quantity)),"Item No.");
                Continue := true;
              end;
            until Continue or (ItemApplEntry.Next = 0);
            ItemApplEntry.Find('-');
            ApplQty := 0;
            repeat
              ApplQty := ApplQty + ItemApplEntry.Quantity;
            until ItemApplEntry.Next = 0;
            if ApplQty <> "Remaining Quantity" then begin
              AddError(
                StrSubstNo(Text013,ItemApplEntry.FieldCaption(Quantity),FieldCaption("Remaining Quantity"),TableCaption),
                "Item No.");
            end;
          end;
        end;
    end;

    procedure CheckValuedByAverageCost()
    begin
        //CheckValuedByAverageCost
        CheckVEValuedBySetting;
        CheckItemApplCostApplSetting;
    end;

    procedure CheckVEValuedBySetting()
    var
        ValueEntry: Record "Value Entry";
        ValueEntry2: Record "Value Entry";
        Continue: Boolean;
    begin
        //CheckVEValuedBySetting
        with "Item Ledger Entry" do begin
          ValueEntry2.SetCurrentKey("Item Ledger Entry No.");
          ValueEntry2.SetRange(Inventoriable,true);
          ValueEntry.SetCurrentKey("Item Ledger Entry No.");
          ValueEntry.SetRange("Item Ledger Entry No.","Entry No.");
          ValueEntry.SetRange(Inventoriable,true);
          if ValueEntry.Find('-') then
            repeat
              if ValueEntry."Item Ledger Entry Type" <> ValueEntry."Item Ledger Entry Type"::Output then
                if "Applies-to Entry" <> 0 then begin
                  ValueEntry2.SetRange("Item Ledger Entry No.","Applies-to Entry");
                  if ValueEntry2.Find('-') then
                    if ValueEntry."Valued By Average Cost" <> ValueEntry2."Valued By Average Cost" then begin
                      AddError(StrSubstNo(Text018,ValueEntry.FieldCaption("Valued By Average Cost")),"Item No.");
                      Continue := true;
                    end;
                end else
                  if (not ValueEntry."Valued By Average Cost") and
                     (ValueEntry."Valuation Date" <> 0D)
                     //NAV2013+.begin
                     // Starting with Dynamics NAV 2013, an outbound Transfer with <blank> Applies-to Entry field
                     // is an accurate combination according to new design.
                     and
                     ("Entry Type" <> "Entry Type"::Transfer) and
                     (Quantity < 0)
                     //NAV2013+.end
                  then begin
                    AddError(StrSubstNo(Text018,ValueEntry.FieldCaption("Valued By Average Cost")),"Item No.");
                    Continue := true;
                  end;
            until (ValueEntry.Next = 0) or Continue;
        end;
    end;

    procedure CheckItemApplCostApplSetting()
    var
        Continue: Boolean;
    begin
        //CheckItemApplCostApplSetting
        with "Item Ledger Entry" do begin
          ItemApplEntry.SetRange("Item Ledger Entry No.","Entry No.");
          if ItemApplEntry.Find('-') then
            repeat
              if ItemApplEntry.Quantity > 0 then begin
                if not ItemApplEntry."Cost Application" then begin
                  AddError(StrSubstNo(Text019,ItemApplEntry.FieldCaption("Cost Application")),"Item No.");
                  Continue := true;
                end;
              end else
                if "Applies-to Entry" <> 0 then begin
                  if not ItemApplEntry."Cost Application" then begin
                    AddError(StrSubstNo(Text019,ItemApplEntry.FieldCaption("Cost Application")),"Item No.");
                    Continue := true;
                  end;
                end else
                  //NAV2013+.begin
                  // Starting with Dynamics NAV 2013, an outbound Transfer with Cost Application set to TRUE
                  // is an accurate combination according to new design.
                  //IF ItemApplEntry."Cost Application" THEN BEGIN
                  if (ItemApplEntry."Cost Application") and ("Entry Type" <> "Entry Type"::Transfer) then begin
                  //NAV2013+.end
                    AddError(StrSubstNo(Text019,ItemApplEntry.FieldCaption("Cost Application")),"Item No.");
                    Continue := true;
                  end;
            until (ItemApplEntry.Next = 0) or Continue;
        end;
    end;

    procedure CheckValuationDate()
    var
        ValueEntry: Record "Value Entry";
        ValuationDate: Date;
        Continue: Boolean;
    begin
        //CheckValuationDate
        with "Item Ledger Entry" do begin
          ValueEntry.SetCurrentKey("Item Ledger Entry No.");
          ValueEntry.SetRange("Item Ledger Entry No.","Entry No.");
          ValueEntry.SetRange(Inventoriable,true);
          ValueEntry.SetRange("Partial Revaluation",false);
          if ValueEntry.Find('-') then begin
            ValuationDate := ValueEntry."Valuation Date";
            ItemApplEntry.SetRange("Inbound Item Entry No.","Entry No.");
            if ItemApplEntry.Find('-') then
              repeat
                if ItemApplEntry.Quantity < 0 then begin
                  ValueEntry.SetRange("Item Ledger Entry No.",ItemApplEntry."Item Ledger Entry No.");
                  if ValueEntry.Find('-') then
                    repeat
                      if ValueEntry."Valuation Date" < ValuationDate then begin
                        AddError(StrSubstNo(Text017,ValueEntry.FieldCaption("Valuation Date"),TableCaption,ValueEntry.TableCaption),
                          "Item No.");
                        Continue := true;
                      end;
                    until (ValueEntry.Next = 0) or Continue;
                end;
              until (ItemApplEntry.Next = 0) or Continue;
          end;
        end;
    end;

    procedure CheckRemainingExpectedAmount()
    var
        ValueEntry: Record "Value Entry";
        TotalExpectedCostToGL: Decimal;
        TotalExpectedCostToGLACY: Decimal;
    begin
        if not "Item Ledger Entry"."Completely Invoiced" then
          exit;

        ValueEntry.SetCurrentKey("Item Ledger Entry No.");
        ValueEntry.SetRange("Item Ledger Entry No.","Item Ledger Entry"."Entry No.");

        "Item Ledger Entry".CalcFields("Cost Amount (Expected)","Cost Amount (Expected) (ACY)");
        if
          ("Item Ledger Entry"."Cost Amount (Expected)" = 0) and
          ("Item Ledger Entry"."Cost Amount (Expected) (ACY)" = 0)
        then begin
          if ValueEntry.FindSet then
            repeat
              TotalExpectedCostToGL := TotalExpectedCostToGL + ValueEntry."Expected Cost Posted to G/L";
              TotalExpectedCostToGLACY := TotalExpectedCostToGLACY + ValueEntry."Exp. Cost Posted to G/L (ACY)";
            until ValueEntry.Next = 0;
          if (TotalExpectedCostToGL = 0) and (TotalExpectedCostToGLACY = 0) then
            exit;
        end;

        if ValueEntry.FindSet then
          repeat
            if (ValueEntry."Expected Cost Posted to G/L" <> 0) or (ValueEntry."Exp. Cost Posted to G/L (ACY)" <> 0) then begin
              AddError(
                StrSubstNo(Text043,
                  ValueEntry.FieldCaption("Expected Cost Posted to G/L"),ValueEntry.FieldCaption("Exp. Cost Posted to G/L (ACY)")),
                ValueEntry."Item No.");

            end;
          until ValueEntry.Next = 0;

        if ErrorIndex > 0 then begin
          AddError(
            StrSubstNo(
              Text045,
              "Item Ledger Entry".FieldCaption("Cost Amount (Expected)"),"Item Ledger Entry".FieldCaption("Cost Amount (Expected) (ACY)")),
            "Item Ledger Entry"."Item No.");
        end;
    end;

    procedure CheckOutputCompletelyInvdDate()
    var
        ItemApplicationEntry: Record "Item Application Entry";
        ZeroDateFound: Boolean;
    begin
        if "Item Ledger Entry"."Invoiced Quantity" <> 0 then
          if "Item Ledger Entry"."Last Invoice Date" = 0D then begin
            AddError(StrSubstNo(Text035,"Item Ledger Entry".FieldCaption("Last Invoice Date")),
              "Item Ledger Entry"."Item No.");
          end;

        ItemApplicationEntry.SetCurrentKey("Item Ledger Entry No.","Output Completely Invd. Date");
        ItemApplicationEntry.SetRange("Item Ledger Entry No.","Item Ledger Entry"."Entry No.");
        if ItemApplicationEntry.FindSet then
          repeat
            if ItemApplicationEntry.Quantity > 0 then begin
              if ItemApplicationEntry."Output Completely Invd. Date" <> ItemApplicationEntry."Posting Date" then begin
                ZeroDateFound := true;
                AddError(
                  StrSubstNo(Text039,
                    ItemApplicationEntry.FieldCaption("Posting Date"),ItemApplicationEntry.FieldCaption("Output Completely Invd. Date")),
                  "Item Ledger Entry"."Item No.");
              end;
            end else begin
              if "Item Ledger Entry".Quantity = "Item Ledger Entry"."Invoiced Quantity" then begin
                if ItemApplicationEntry."Output Completely Invd. Date" <> "Item Ledger Entry"."Last Invoice Date" then begin
                  ZeroDateFound := true;
                  AddError(
                    StrSubstNo(Text041,
                      ItemApplicationEntry.FieldCaption("Output Completely Invd. Date"),
                      "Item Ledger Entry".FieldCaption("Last Invoice Date")),
                    "Item Ledger Entry"."Item No.");
                end;
              end else
                if ItemApplicationEntry."Output Completely Invd. Date" <> 0D then begin
                  ZeroDateFound := true;
                  AddError(
                    StrSubstNo(Text040,ItemApplicationEntry.FieldCaption("Output Completely Invd. Date")),
                    "Item Ledger Entry"."Item No.");

                end;
            end;
          until ZeroDateFound or (ItemApplicationEntry.Next = 0);
    end;

    procedure CheckItem(ItemNo: Code[20])
    begin
        if ItemNo = '' then
          AddError(StrSubstNo(Text052,Item.FieldCaption("No."),Item.TableCaption),ItemNo);
    end;

    procedure AddError(ErrorMessage: Text[250];ItemNo: Code[20])
    begin
        ErrorText[ErrorIndex] := ErrorMessage;
        ErrorIndex := ErrorIndex + 1;

        if Item2.Get(ItemNo) then begin
          ItemTemp := Item2;
          if ItemTemp.Insert then;
        end;
    end;
}

