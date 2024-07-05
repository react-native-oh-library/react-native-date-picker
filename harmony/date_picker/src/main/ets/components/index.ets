import { JSON } from '@kit.ArkTS';
import Logger from './Logger'
import {
  Descriptor,
  ViewRawProps,
  ViewBaseProps,
  RNViewBase,
  RNComponentContext
} from '@rnoh/react-native-openharmony';
import { RNC } from "@rnoh/react-native-openharmony/generated/ts"


interface NativeDatePickerProps extends ViewRawProps {
  mode?: string | undefined;
  date?: string | undefined;
  open?: boolean | undefined;
  modal?:boolean | undefined;
  onConfirm?:(timestamp:string) => void
  onDateChange?:(timestamp:string) => void
  onChange?:(timestamp:string) => void
  onCancel?:() => void
  maximumDate?: string | undefined
  minimumDate?: string | undefined
}
export interface AutoLayoutProps {}
export type NativeDatePickerDescriptor = Descriptor<"NativeDatePickerView", ViewBaseProps,AutoLayoutProps,NativeDatePickerProps>

@Component
export struct NativeDatePickerView {
  public static readonly NAME = RNC.NativeDatePickerView.NAME
  public ctx!: RNComponentContext
  public tag: number = 0
  @State descriptor: NativeDatePickerDescriptor = {} as NativeDatePickerDescriptor
  @State date: string  = new Date().toString()
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
  addZero(e:number) : string{
    if(e < 10){
      return  0 +''+e
    }
    return e +''
  }
  getDate(e:string) : string{
    let y = new Date(e).getFullYear()
    let M = this.addZero(new Date(e).getMonth() + 1)
    let d = this.addZero(new Date(e).getDate())
    let h = this.addZero(new Date(e).getHours())
    let m = this.addZero(new Date(e).getMinutes())
    let s = this.addZero(new Date(e).getSeconds())
    let date =y + '-' + M + '-' + d + ' '+ h + ':' + m + ':' + s
    Logger.info(date, 'getDate')
    return date
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
            this.eventEmitter!.emit("dateChange", {timestamp: this.getDate(value.toString())})
          }).height(200)
        }
        else if(this.descriptor.rawProps.mode === 'datetime'){
          Column(){
            Flex() { // 子组件在容器主轴上反向行布局
              DatePicker({
                start: new Date(this.descriptor.rawProps.minimumDate),
                end: new Date(this.descriptor.rawProps.maximumDate),
              }).onDateChange((value: Date) => {
                let y = new Date(value).getFullYear()
                let M = this.addZero(new Date(value).getMonth() + 1)
                let d =this.addZero(new Date(value).getDate())
                let h = this.addZero(new Date(this.date).getHours())
                let m = this.addZero(new Date(this.date).getMinutes())
                let s = this.addZero(new Date(this.date).getSeconds())
                let stDate = y + '-' + M + '-' + d + ' '+ h + ':' + m + ':' + s
                Logger.info(stDate, 'datetimeChange')
                this.date = new Date(stDate).toString()
                this.eventEmitter!.emit("dateChange", { timestamp: stDate })
              }).width('53%').height(200)
              TimePicker().onChange((value: TimePickerResult) => {
                let y = new Date(this.date).getFullYear()
                let M = this.addZero(new Date(this.date).getMonth() + 1)
                let d = this.addZero(new Date(this.date).getDate())
                let stDate = y + '-' + M + '-' + d + '-' +' '+ value.hour+':'+ value.minute+':'+ '00'
                this.date = new Date(stDate).toString()
                Logger.info(stDate, 'datetimeChange')
                this.eventEmitter!.emit("dateChange", { timestamp: this.date })
              }).width('47%').height(200)
            }
          }
        }
        else if(this.descriptor.rawProps.mode === 'time'){
          TimePicker().onChange((value: TimePickerResult) => {
            this.eventEmitter!.emit("dateChange", {timestamp:this.getDate(value.toString())})
          }).height(200)
        }
      }else{
        // modal
        if(this.descriptor.rawProps.open){
          if(this.descriptor.rawProps.mode === 'date'){
            Column().onAppear(()=>{
              CalendarPickerDialog.show({
                selected:new Date(this.descriptor.rawProps.date),
                onAccept: (value: Date) => {
                  this.eventEmitter!.emit("confirm", {timestamp:  this.getDate(value.toString())})
                  Logger.info("DatePickerDialog:onDateAccept()" + value.toString())
                },
                onCancel: () => {
                  this.eventEmitter!.emit("cancel",  {})
                  Logger.info("calendar onCancel")
                },
                onChange: (value: Date) => {
                  this.eventEmitter!.emit("change", {timestamp: this.getDate(value.toString())})
                  Logger.info("DatePickerDialog:onDateChange()" + value.toString())
                },
                onDidDisappear:()=>{
                  this.eventEmitter!.emit("cancel",  {})
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
                  this.eventEmitter!.emit("confirm", { timestamp: this.getDate(value.toString()) })
                  Logger.info("DatePickerDialog:onDateAccept()" + value.toString())
                },
                onCancel: () => {
                  this.eventEmitter!.emit("cancel",  {})
                  Logger.info("DatePickerDialog:onCancel()")
                },
                onDateChange: (value: Date) => {
                  this.eventEmitter!.emit("change", { timestamp: this.getDate(value.toString()) })
                  Logger.info("DatePickerDialog:onDateChange()" + value.toString())
                },
                onDidDisappear:()=>{
                  this.eventEmitter!.emit("cancel",  {})
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
                    let y = new Date().getFullYear()
                    let M = this.addZero(new Date().getMonth() + 1)
                    let d = this.addZero(new Date().getDate())
                    let stDate = y + '-' + M + '-' + d + '-' +' '+ this.addZero(value.hour)+':'+ this.addZero(value.minute)+':'+ '00'
                    this.eventEmitter!.emit("confirm", { timestamp: stDate })
                    Logger.info("TimePickerDialog:onAccept()" + stDate)
                  }
                },
                onCancel: () => {
                  this.eventEmitter!.emit("cancel",  {})
                  Logger.info("TimePickerDialog:onCancel()")
                },
                onChange: (value: TimePickerResult) => {
                  let y = new Date().getFullYear()
                  let M = this.addZero(new Date().getMonth() + 1)
                  let d = this.addZero(new Date().getDate())
                  let stDate = y + '-' + M + '-' + d + '-' +' '+ this.addZero(value.hour)+':'+ this.addZero(value.minute)+':'+ '00'
                  this.eventEmitter!.emit("change", { timestamp: stDate })
                  Logger.info("TimePickerDialog:onChange()" + stDate)
                },
                onDidDisappear:()=>{
                  this.eventEmitter!.emit("cancel",  {})
                }
              })
            })
          }
        }
      }
    }
  }
}
