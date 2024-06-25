import {
  Descriptor,
  ViewRawProps,
  ViewBaseProps,
  RNViewBase,
  RNComponentContext
} from '@rnoh/react-native-openharmony';
import { RNC } from "@rnoh/react-native-openharmony/generated/ts"
import { JSON } from '@kit.ArkTS';

interface NativeDatePickerProps extends ViewRawProps {
  mode?: string;
  date?: string;
  open?: boolean;
  modal?:boolean;
  onConfirm?:(timestamp:string) => void
  onDateChange?:(timestamp:string) => void
  onChange?:() => void
  onCancel?:() => void
  maximumDate?: string
  minimumDate?: string
}
export interface AutoLayoutProps {}
export type NativeDatePickerDescriptor = Descriptor<"NativeDatePickerView", ViewBaseProps,AutoLayoutProps,NativeDatePickerProps>

@Component
export struct NativeDatePickerView {
  public static readonly NAME = RNC.NativeDatePickerView.NAME
  public ctx!: RNComponentContext
  public tag: number = 0
  @State descriptor: NativeDatePickerDescriptor = {} as NativeDatePickerDescriptor
  @State fontSize: number | undefined = undefined
  private cleanUpCallbacks: (() => void)[] = []
  private eventEmitter: RNC.NativeDatePickerView.EventEmitter | undefined = undefined
  aboutToAppear() {
    this.eventEmitter = new RNC.NativeDatePickerView.EventEmitter(this.ctx.rnInstance, this.tag)
    this.descriptor = this.ctx.descriptorRegistry.getDescriptor<NativeDatePickerDescriptor>(this.tag)
    this.cleanUpCallbacks.push(this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      (newDescriptor) => {
        this.descriptor = (newDescriptor as NativeDatePickerDescriptor)
      }
    ))
  }

  aboutToDisappear() {
    this.cleanUpCallbacks.forEach(cb => cb())
  }

  build() {
    RNViewBase({ ctx: this.ctx, tag: this.tag }) {
      if(!this.descriptor.rawProps.modal){
      // inline
      if(this.descriptor.rawProps.mode === 'date'){
          DatePicker({
            start: new Date(this.descriptor.rawProps.minimumDate),
            end: new Date(this.descriptor.rawProps.maximumDate),
            }).onDateChange((value: Date) => {
            this.eventEmitter!.emit("dateChange", {timestamp: JSON.stringify(value)})
          }).height(300)
      }else if(this.descriptor.rawProps.mode === 'datetime'){
      // 不支持
      }else if(this.descriptor.rawProps.mode === 'time'){
          TimePicker().onChange((value: TimePickerResult) => {
            this.eventEmitter!.emit("dateChange", {timestamp: JSON.stringify(value)})
          }).height(300)
      }
      }else{
        // modal
        if(this.descriptor.rawProps.open){
          if(this.descriptor.rawProps.mode === 'date'){
            Column().onAppear(()=>{
              CalendarPickerDialog.show({
                selected:new Date(this.descriptor.rawProps.date),
                onAccept: (value: Date) => {
                  // this.selectedDate = value
                  this.eventEmitter!.emit("confirm", {timestamp: JSON.stringify(value)})
                  console.info("DatePickerDialog:onDateAccept()" + value.toString())
                },
                onCancel: () => {
                  this.eventEmitter!.emit("cancel",  {})  
                },
                onChange: (value: Date) => {
                  this.eventEmitter!.emit("change", {timestamp: JSON.stringify(value)})
                  console.info("DatePickerDialog:onDateChange()" + value.toString())
                }
              })
            })
          }else if(this.descriptor.rawProps.mode === 'datetime'){
            Column().onAppear(()=> {
              DatePickerDialog.show({
                showTime: true,
                selected: new Date(this.descriptor.rawProps.date),
                start: new Date(this.descriptor.rawProps.minimumDate),
                end: new Date(this.descriptor.rawProps.maximumDate),
                onDateAccept: (value: Date) => {
                  this.eventEmitter!.emit("confirm", { timestamp: JSON.stringify(value) })
                  console.info("DatePickerDialog:onDateAccept()" + value.toString())
                },
                onCancel: () => {
                  this.eventEmitter!.emit("cancel",  {})
                  console.info("DatePickerDialog:onCancel()")
                },
                onDateChange: (value: Date) => {
                  this.eventEmitter!.emit("change", { timestamp: JSON.stringify(value) })
                  console.info("DatePickerDialog:onDateChange()" + value.toString())
                }
              })
            })
          }else if(this.descriptor.rawProps.mode === 'time'){
            Column().onAppear(()=> {
              TimePickerDialog.show({
                selected: new Date(this.descriptor.rawProps.date),
                onAccept: (value: TimePickerResult) => {
                  // 设置selectTime为按下确定按钮时的时间，这样当弹窗再次弹出时显示选中的为上一次确定的时间
                  if (value.hour != undefined && value.minute != undefined) {
                    this.eventEmitter!.emit("confirm", { timestamp: JSON.stringify(value) })
                    console.info("TimePickerDialog:onAccept()" + JSON.stringify(value))
                  }
                },
                onCancel: () => {
                  this.eventEmitter!.emit("cancel",  {})
                  console.info("TimePickerDialog:onCancel()")
                },
                onChange: (value: TimePickerResult) => {
                  this.eventEmitter!.emit("change", { timestamp: JSON.stringify(value) })  
                  console.info("TimePickerDialog:onChange()" + JSON.stringify(value))
                }

              })
            })
          }

        }
      }
    }
  }
}
