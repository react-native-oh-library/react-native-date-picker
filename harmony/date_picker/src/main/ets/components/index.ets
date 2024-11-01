/**
 * MIT License
 *
 * Copyright (C) 2024 Huawei Device Co., Ltd.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import { RNComponentContext, RNViewBase } from '@rnoh/react-native-openharmony';
import { RNC } from "@rnoh/react-native-openharmony/generated/ts"
import { formatDateByTime, mergeObject, formatDate, formatTime, addZero } from '../utils'

@Component
export struct RNDatePicker {
  public static readonly NAME = RNC.RNDatePicker.NAME
  public ctx!: RNComponentContext
  public tag: number = 0;
  @State private descriptorWrapper: RNC.RNDatePicker.DescriptorWrapper = {} as RNC.RNDatePicker.DescriptorWrapper
  private eventEmitter: RNC.RNDatePicker.EventEmitter | undefined = undefined
  private cleanUpCallbacks: (() => void)[] = []
  @State private dateTime: number = 0

  aboutToAppear() {
    this.eventEmitter = new RNC.RNDatePicker.EventEmitter(this.ctx.rnInstance, this.tag)
    this.onDescriptorWrapperChange(this.ctx.descriptorRegistry.getDescriptor<RNC.RNDatePicker.Descriptor>(this.tag)!)
    this.cleanUpCallbacks.push(this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      descriptor => {
        this.onDescriptorWrapperChange(descriptor! as RNC.RNDatePicker.Descriptor)
      }
    ));
  }

  private onDescriptorWrapperChange(descriptor: RNC.RNDatePicker.Descriptor) {
    this.descriptorWrapper = new RNC.RNDatePicker.DescriptorWrapper(descriptor);
    this.dateTime = this.descriptorWrapper.props.date;
    //处理modal为false,默认date和可选时间范围问题
    if(this.descriptorWrapper.props.minimumDate){
      const minimumDate = this.descriptorWrapper.props.minimumDate;
      if(this.dateTime<minimumDate){
        this.dateTime = minimumDate;
      }
    }
    if(this.descriptorWrapper.props.maximumDate){
      const maximumDate = this.descriptorWrapper.props.maximumDate;
      if(this.dateTime>maximumDate){
        this.dateTime = maximumDate;
      }
    }
    this.initShowDatePicker()
  }

  private initShowDatePicker() {
    if (this.descriptorWrapper.props.modal && this.descriptorWrapper.props.open) {
      if (this.descriptorWrapper.props.mode === 'date') {
        this.showDatePickerDialog()
      } else if (this.descriptorWrapper.props.mode === 'datetime') {
        this.showDatePickerDialog({ showTime: true })
      } else if (this.descriptorWrapper.props.mode === 'time') {
        this.showTimePickerDialog()
      }
    }
  }

  private showDatePickerDialog(params?: DatePickerDialogOptions) {
    params = !params ? {} : params
    DatePickerDialog.show(mergeObject(params, {
      selected: new Date(this.descriptorWrapper.props.date),
      start: this.descriptorWrapper.props.minimumDate ? new Date(this.descriptorWrapper.props.minimumDate) : null,
      end: this.descriptorWrapper.props.maximumDate ? new Date(this.descriptorWrapper.props.maximumDate) : null,
      onDateAccept: (value: Date) => {
        this.eventEmitter!.emit("confirm", { timestamp: new Date(value).getTime() })
      },
      onCancel: () => {
        this.eventEmitter!.emit("cancel", {})
      },
      onDateChange: (value: Date) => {
        this.eventEmitter!.emit("change", { timestamp: new Date(value).getTime() })
      },
    }))
  }

  private showTimePickerDialog() {
    TimePickerDialog.show({
      selected: new Date(this.descriptorWrapper.props.date),
      onAccept: (value: TimePickerResult) => {
        const time = formatDateByTime(value.hour, value.minute, 0)
        this.eventEmitter!.emit("confirm", { timestamp: new Date(time).getTime() })
      },
      onCancel: () => {
        this.eventEmitter!.emit("cancel", {})
      },
      onChange: (value: TimePickerResult) => {
        const time = formatDateByTime(value.hour, value.minute, 0)
        this.eventEmitter!.emit("change", { timestamp: new Date(time).getTime() })
      },
    })
  }

  aboutToDisappear() {
    this.cleanUpCallbacks.forEach(cb => cb());
  }

  @Builder
  showDatePicker() {
    DatePicker({
      start: this.descriptorWrapper.props.minimumDate ? new Date(this.descriptorWrapper.props.minimumDate) : null,
      end: this.descriptorWrapper.props.maximumDate ? new Date(this.descriptorWrapper.props.maximumDate) : null,
      selected: new Date(this.descriptorWrapper.props.date)
    }).onDateChange((value: Date) => {
      let timestamp = new Date(value).getTime()
      if (this.descriptorWrapper.props.mode === 'datetime') {
        this.dateTime = new Date(formatDate(value) + ' ' + formatTime(this.dateTime)).getTime()
        timestamp = this.dateTime;
      }
      this.eventEmitter!.emit("change", { timestamp: timestamp })
    }).height(216)
  }

  @Builder
  showTimePicker() {
    TimePicker({
      selected: new Date(this.descriptorWrapper.props.date),
    }).onChange((value: TimePickerResult) => {
      const time = formatDateByTime(value.hour, value.minute, 0)
      let timestamp = new Date(time).getTime()
      if (this.descriptorWrapper.props.mode === 'datetime') {
        this.dateTime =
          new Date(formatDate(this.dateTime) + ' ' + addZero(value.hour) + ':' + addZero(value.minute) + ':' +
            '00').getTime()
        timestamp = this.dateTime;
      }
      this.eventEmitter!.emit("change", { timestamp: timestamp })
    }).height(216)
  }

  build() {
    RNViewBase({ ctx: this.ctx, tag: this.tag }) {
      if (!this.descriptorWrapper.props.modal) {
        if (this.descriptorWrapper.props.mode === 'date') {
          this.showDatePicker()
        } else if (this.descriptorWrapper.props.mode === 'datetime') {
          Row() {
            Column() {
              this.showDatePicker()
            }.width('53%').height('100%')

            Column() {
              this.showTimePicker()
            }.width('47%').height('100%')
          }
        } else if (this.descriptorWrapper.props.mode === 'time') {
          this.showTimePicker()
        }
      }
    }
  }
}