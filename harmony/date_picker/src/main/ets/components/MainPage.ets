import {
  Descriptor,
  ViewBaseProps,
  RNViewBase,
  RNComponentContext
} from '@rnoh/react-native-openharmony';
import { RNC } from "@rnoh/react-native-openharmony/generated/ts"

interface NativeDatePickerProps extends ViewBaseProps {
  mode?: string;
  onConfirm?:(timestamp:string) => void
}

export type NativeDatePickerDescriptor = Descriptor<"NativeDatePickerView", NativeDatePickerProps>

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
    // RNViewBase({ ctx: this.ctx, tag: this.tag }) {
      Column() {
        Button('时间')
          .margin(20)
          .onClick(() => {
            console.info("CalendarDialog.show2" + JSON.stringify(this.descriptor))
            if (this.descriptor.props.mode === 'date') {
              console.log("CalendarDialog.show3")
              CalendarPickerDialog.show({
                selected:new Date(),
                onAccept: (value: Date) => {
                  this.eventEmitter!.emit("confirm", {timestamp: JSON.stringify(value)  })
                  console.info("DatePickerDialog:onDateAccept()" + value.toString())
                },
                onCancel: () => {
                  console.info("DatePickerDialog:onCancel()")
                },
                onChange: (value: Date) => {
                  // this.descriptor.props.onBubblingEvent(value as Date)
                  console.info("DatePickerDialog:onDateChange()" + value.toString())
                }
              })
            }
            else if (this.descriptor.props.mode === 'datetime') {
              DatePickerDialog.show({
                showTime:true,
                selected:new Date(),
                onDateAccept: (value: Date) => {
                  this.eventEmitter!.emit("confirm", {timestamp: JSON.stringify(value)  })
                  console.info("DatePickerDialog:onDateAccept()" + value.toString())
                },
                onCancel: () => {
                  console.info("DatePickerDialog:onCancel()")
                },
                onDateChange: (value: Date) => {
                  // this.descriptor.props.onBubblingEvent(value as Date)
                  console.info("DatePickerDialog:onDateChange()" + value.toString())
                }
              })
            } else if (this.descriptor.props.mode === 'time') {
              TimePickerDialog.show({
                selected:new Date(),
                onAccept: (value: TimePickerResult) => {
                  this.eventEmitter!.emit("confirm", {timestamp: value.toString()  })
                  console.info("DatePickerDialog:onDateAccept()" + value.toString())
                },
                onCancel: () => {
                  console.info("DatePickerDialog:onCancel()")
                },
                onChange: (value: TimePickerResult) => {
                  // this.descriptor.props.onBubblingEvent(value as Date)
                  console.info("DatePickerDialog:onDateChange()" + value.toString())
                }
              })
            }

          })
      }.width('100%').margin(20)
      // this.ctx.wrappedRNChildrenBuilder.builder(this.ctx, this.tag)
    // }
  }
}
