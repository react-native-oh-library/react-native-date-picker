import React, { useCallback } from 'react'
import { getNativeComponent } from './modules'

const NativeComponent = getNativeComponent()

/** @type {React.FC<PlatformPickerProps>} */
export const DatePickerHarmony = (props) => {
  const onChange = useCallback(
    /** @param {{ nativeEvent: { timestamp: string } }} event */
    (event) => {
      const nativeTimeStamp = event.nativeEvent.timestamp
      if (props.onDateChange) props.onDateChange(new Date(nativeTimeStamp))
    },
    [props]
  )

  const onConfirm = useCallback(
    /** @param {{ nativeEvent: { timestamp: string } }} event */
    (event) => {
      const nativeTimeStamp = event.nativeEvent.timestamp
      if (props.onConfirm) props.onConfirm(new Date(nativeTimeStamp))
    },
    [props]
  )



  /** @type {NativeProps}  */
  const modifiedProps = {
    ...props,
    style: [props.style],
    date: props.date ? props.date.getTime() : undefined,
    locale: props.locale ? props.locale : undefined,
    maximumDate: props.maximumDate ? props.maximumDate.getTime() : undefined,
    minimumDate: props.minimumDate ? props.minimumDate.getTime() : undefined,
    theme: props.theme ? props.theme : 'auto',
  }

  return (
    <NativeComponent
      {...modifiedProps}
      onChange={onChange}
      onConfirm={onConfirm}
      onStartShouldSetResponder={() => true}
      onResponderTerminationRequest={() => false}
    />
  )
}